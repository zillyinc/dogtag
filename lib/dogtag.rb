require 'redis'
require 'dogtag/mixins/redis'

module Dogtag
  extend Dogtag::Mixins::Redis

  CUSTOM_EPOCH = 1483228800000 # in milliseconds

  TIMESTAMP_BITS = 40
  LOGICAL_SHARD_ID_BITS = 3
  DATA_TYPE_BITS = 9
  SEQUENCE_BITS = 11

  MIN_LOGICAL_SHARD_ID = 0
  MAX_LOGICAL_SHARD_ID = ~(-1 << LOGICAL_SHARD_ID_BITS)
  LOGICAL_SHARD_ID_ALLOWED_RANGE = (MIN_LOGICAL_SHARD_ID..MAX_LOGICAL_SHARD_ID).freeze

  MIN_DATA_TYPE = 0
  MAX_DATA_TYPE = ~(-1 << DATA_TYPE_BITS)
  DATA_TYPE_ALLOWED_RANGE = (MIN_DATA_TYPE..MAX_DATA_TYPE).freeze

  MAX_SEQUENCE = ~(-1 << SEQUENCE_BITS)

  SEQUENCE_SHIFT = 0
  DATA_TYPE_SHIFT = SEQUENCE_BITS
  LOGICAL_SHARD_ID_SHIFT = SEQUENCE_BITS + DATA_TYPE_BITS
  TIMESTAMP_SHIFT = SEQUENCE_BITS + DATA_TYPE_BITS + LOGICAL_SHARD_ID_BITS

  LOGICAL_SHARD_ID_KEY = 'dogtag-generator-logical-shard-id'.freeze

  def self.logical_shard_id=(logical_shard_id)
    unless logical_shard_id.is_a? Integer
      raise ArgumentError, 'logical_shard_id must be an integer'
    end

    unless Dogtag::LOGICAL_SHARD_ID_ALLOWED_RANGE.include? logical_shard_id
      raise ArgumentError, "logical_shard_id is outside the allowed range of #{Dogtag::LOGICAL_SHARD_ID_ALLOWED_RANGE}"
    end

    redis.set LOGICAL_SHARD_ID_KEY, logical_shard_id
  end

  def self.generate_id(data_type)
    Generator.new(data_type, 1).ids.first
  end

  def self.generate_ids(data_type, count)
    ids = []

    # The Lua script can't always return as many IDs as you may want. So we loop
    # until we have the exact amount.
    while ids.length < count
      initial_id_count = ids.length
      ids += Generator.new(data_type, count - ids.length).ids

      # Ensure the ids array keeps growing as infinite loop insurance
      return ids unless ids.length > initial_id_count
    end

    ids
  end
end

require 'dogtag/generator'
require 'dogtag/id'
require 'dogtag/request'
require 'dogtag/response'
require 'dogtag/timestamp'
