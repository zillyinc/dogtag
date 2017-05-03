module Icicle
  class Generator
    def initialize(count = 1)
      @count = count
    end

    def ids
      response.sequence.map do |sequence|
        # shifted_timestamp | shifted_logical_shard_id | sequence
        shifted_timestamp | shifted_logical_shard_id | sequence
      end
    end

    private

    attr_reader :count

    def shifted_timestamp
      custom_timestamp << Icicle::TIMESTAMP_SHIFT
    end

    def custom_timestamp
      timestamp - Icicle::CUSTOM_EPOCH
    end

    def timestamp
      # Convert seconds and microseconds to milliseconds
      (response.seconds * Icicle::ONE_SECOND_IN_MILLIS) + (response.microseconds / Icicle::ONE_MILLI_IN_MICRO_SECS)
    end

    def shifted_logical_shard_id
      response.logical_shard_id << Icicle::LOGICAL_SHARD_ID_SHIFT
    end

    def response
      @response ||= Request.new(count).response
    end
  end
end
