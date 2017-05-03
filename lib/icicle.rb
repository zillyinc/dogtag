require 'redis'
require 'icicle/mixins/redis'

module Icicle
  extend Icicle::Mixins::Redis

  CUSTOM_EPOCH = 1483228800000 # in milliseconds

  TIMESTAMP_BITS = 41
  LOGICAL_SHARD_ID_BITS = 10
  SEQUENCE_BITS = 12

  SEQUENCE_SHIFT = 0
  LOGICAL_SHARD_ID_SHIFT = SEQUENCE_BITS
  TIMESTAMP_SHIFT = SEQUENCE_BITS + LOGICAL_SHARD_ID_BITS

  LOGICAL_SHARD_ID_KEY = 'icicle-generator-logical-shard-id'.freeze

  def self.logical_shard_id=(logical_shard_id)
    redis.set LOGICAL_SHARD_ID_KEY, logical_shard_id
  end

  def self.generate_id
    Generator.new(1).ids.first
  end

  def self.generate_ids(count)
    Generator.new(count).ids
  end
end

require 'icicle/generator'
require 'icicle/id'
require 'icicle/request'
require 'icicle/response'
require 'icicle/timestamp'
