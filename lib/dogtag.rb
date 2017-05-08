require 'redis'
require 'dogtag/mixins/redis'

module Dogtag
  extend Dogtag::Mixins::Redis

  CUSTOM_EPOCH = 1483228800000 # in milliseconds

  TIMESTAMP_BITS = 41
  LOGICAL_SHARD_ID_BITS = 10
  SEQUENCE_BITS = 12

  SEQUENCE_SHIFT = 0
  LOGICAL_SHARD_ID_SHIFT = SEQUENCE_BITS
  TIMESTAMP_SHIFT = SEQUENCE_BITS + LOGICAL_SHARD_ID_BITS

  LOGICAL_SHARD_ID_KEY = 'dogtag-generator-logical-shard-id'.freeze

  def self.logical_shard_id=(logical_shard_id)
    redis.set LOGICAL_SHARD_ID_KEY, logical_shard_id
  end

  def self.generate_id
    Generator.new(1).ids.first
  end

  def self.generate_ids(count)
    ids = []

    # The Lua script can't always return as many IDs as you may want. So we loop
    # until we have the exact amount.
    while ids.length < count
      initial_id_count = ids.length
      ids += Generator.new(count - ids.length).ids

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
