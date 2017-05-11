module Dogtag
  module Mixins
    module Redis
      def redis
        # TODO: Redis config for multiple servers
        @redis ||= ::Redis.new
      end
    end
  end
end
