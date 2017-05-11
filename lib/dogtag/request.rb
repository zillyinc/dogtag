module Dogtag
  class Request
    include Dogtag::Mixins::Redis

    LUA_SCRIPT_PATH = 'lua/id-generation.lua'.freeze
    MAX_TRIES = 5

    def initialize(data_type, count = 1)
      raise ArgumentError, 'data_type must be a number' unless data_type.is_a? Numeric
      unless Dogtag::DATA_TYPE_ALLOWED_RANGE.include? data_type
        raise ArgumentError, "data_type is outside the allowed range of #{Dogtag::DATA_TYPE_ALLOWED_RANGE}"
      end
      raise ArgumentError, 'count must be a number' unless count.is_a? Numeric
      raise ArgumentError, 'count must be greater than zero' unless count > 0

      @tries = 0
      @data_type = data_type
      @count = count
    end

    def response
      Response.new(try_redis_response)
    end

    private

    attr_reader :data_type, :count

    def lua_script
      File.read(
        File.expand_path "../../#{LUA_SCRIPT_PATH}", File.dirname(__FILE__)
      )
    end

    def lua_args
      lua_args = [ MAX_SEQUENCE, data_type, count ]
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
