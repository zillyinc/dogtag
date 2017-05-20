module Dogtag
  module Mixins
    module Redis
      DEFAULT_REDIS_URL = 'redis://localhost:6379'.freeze

      def redis
        # TODO: Redis config for multiple servers
        @redis ||= ::Redis.new(
          url: ENV['DOGTAG_REDIS_URL'] || ENV['REDIS_URL'] || DEFAULT_REDIS_URL
        )
      end
    end
  end
end
