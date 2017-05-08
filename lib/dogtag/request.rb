module Dogtag
  class Request
    include Dogtag::Mixins::Redis

    MAX_SEQUENCE = ~(-1 << Dogtag::SEQUENCE_BITS)
    MIN_LOGICAL_SHARD_ID = 1
    MAX_LOGICAL_SHARD_ID = ~(-1 << Dogtag::LOGICAL_SHARD_ID_BITS)
    LUA_SCRIPT_PATH = 'lua/id-generation.lua'.freeze
    MAX_TRIES = 5

    def initialize(count = 1)
      raise ArgumentError, 'count must be a number' unless count.is_a? Numeric
      raise ArgumentError, 'count must be greater than zero' unless count > 0

      @tries = 0
      @count = count
    end

    def response
      Response.new(try_redis_response)
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

    # NOTE: If too many requests come in inside of a millisecond the Lua script
    # will lock for 1ms and throw an error. This is meant to retry in those cases.
    def try_redis_response
      begin
        @tries += 1
        redis_response
      rescue Redis::CommandError => err
        if @tries < MAX_TRIES
          # Exponentially sleep more and more on each try
          sleep (@tries * @tries).to_f / 900
          retry
        else
          raise err
        end
      end
    end

    def redis_response
      @redis_response ||= redis.eval(lua_script, keys: lua_args)
    end
  end
end
