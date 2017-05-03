module Icicle
  class Request
    include Icicle::Mixins::Redis

    MAX_SEQUENCE = ~(-1 << Icicle::SEQUENCE_BITS)
    MIN_LOGICAL_SHARD_ID = 1
    MAX_LOGICAL_SHARD_ID = ~(-1 << Icicle::LOGICAL_SHARD_ID_BITS)
    LUA_SCRIPT_PATH = 'lua/id-generation.lua'.freeze

    def initialize(count = 1)
      raise ArgumentError, 'count must be a number' unless count.is_a? Numeric
      raise ArgumentError, 'count must be greater than zero' unless count > 0

      @count = count
    end

    def response
      Response.new(redis_response)
    end

    private

    attr_reader :count

    def lua_script
      File.read(
        File.expand_path "../../#{LUA_SCRIPT_PATH}", File.dirname(__FILE__)
      )
    end

    def lua_args
      lua_args = [
        MAX_SEQUENCE,
        MIN_LOGICAL_SHARD_ID,
        MAX_LOGICAL_SHARD_ID,
        count
      ]
    end

    def redis_response
      # TODO: watch for `Redis::CommandError: Icicle: Cannot generate ID, waiting for lock to expire.` and retry
      @redis_response ||= redis.eval(lua_script, keys: lua_args)
    end
  end
end
