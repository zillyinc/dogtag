module Icicle
  module Mixins
    module Redis
      def redis
        # TODO: Redis config
        @redis ||= ::Redis.new
      end
    end
  end
end
