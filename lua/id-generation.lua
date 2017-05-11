local logical_shard_id_range_key = 'dogtag-generator-logical-shard-id-range'

local max_sequence = tonumber(KEYS[1])
local data_type = tonumber(KEYS[2])
local num_ids = tonumber(KEYS[3])

--[[
Scope lock and sequence keys to the specific data_type being requested.
Ideally, we'd also use the logical_shard_id in the keys so that any per-millisecond limitations would only be per-shard,
but unfortunately the whole "pure function" limitation keeps us from using a random shard_id here. The best solution may
be to round robin the shard ID by incrementing a Redis key on each call
]]--
local lock_key = 'data-type-' .. data_type .. '-dogtag-generator-lock'
local sequence_key = 'data-type-' .. data_type .. '-dogtag-generator-sequence'

if redis.call('EXISTS', lock_key) == 1 then
  redis.log(redis.LOG_NOTICE, 'Dogtag: Cannot generate ID, waiting for lock to expire.')
  return redis.error_reply('Dogtag: Cannot generate ID, waiting for lock to expire.')
end

-- Increment by a set number
local end_sequence = redis.call('INCRBY', sequence_key, num_ids)
local start_sequence = end_sequence - num_ids + 1

-- Allow one server to acts as multiple shards
local logical_shard_id_range = redis.call('SORT', logical_shard_id_range_key)
if next(logical_shard_id_range) == nil then
  redis.log(redis.LOG_NOTICE, 'Dogtag: ' .. logical_shard_id_range_key .. ' has not been set.')
  return redis.error_reply('Dogtag: ' .. logical_shard_id_range_key .. ' has not been set.')
end
local logical_shard_id_min = tonumber(logical_shard_id_range[1])
local logical_shard_id_max = tonumber(logical_shard_id_range[2])

if end_sequence >= max_sequence then
  --[[
  As the sequence is about to roll around, we can't generate another ID until we're sure we're not in the same
  millisecond since we last rolled. This is because we may have already generated an ID with the same time and
  sequence, and we cannot allow even the smallest possibility of duplicates. It's also because if we roll the sequence
  around, we will start generating IDs with smaller values than the ones previously in this millisecond - that would
  break our k-ordering guarantees!

  The only way we can handle this is to block for a millisecond, as we can't store the time due the purity constraints
  of Redis Lua scripts.

  In addition to a neat side-effect of handling leap seconds (where milliseconds will last a little bit longer to bring
  time back to where it should be) because Redis uses system time internally to expire keys, this prevents any duplicate
  IDs from being generated if the rate of generation is greater than the maximum sequence per millisecond.

  Note that it only blocks even it rolled around *not* in the same millisecond; this is because unless we do this, the
  IDs won't remain ordered.
  --]]
  redis.log(redis.LOG_NOTICE, 'Dogtag: Rolling sequence back to the start, locking for 1ms.')
  redis.call('SET', sequence_key, '-1')
  redis.call('PSETEX', lock_key, 1, 'lock')
  end_sequence = max_sequence
end

--[[
The TIME command MUST be called after anything that mutates state, or the Redis server will error the script out.
This is to ensure the script is "pure" in the sense that randomness or time based input will not change the
outcome of the writes.

See the "Scripts as pure functions" section at http://redis.io/commands/eval for more information.
--]]
local time = redis.call('TIME')

-- Redis Lua doesn't really do random without a seed. It's part of the whole "pure function" thing
math.randomseed(time[2])

local logical_shard_id = math.random(logical_shard_id_min, logical_shard_id_max)

return {
  start_sequence,
  end_sequence, -- Doesn't need conversion, the result of INCR or the variable set is always a number.
  logical_shard_id,
  tonumber(time[1]),
  tonumber(time[2])
}
