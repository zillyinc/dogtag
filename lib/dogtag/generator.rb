module Dogtag
  class Generator
    def initialize(count = 1)
      @count = count
    end

    def ids
      response.sequence.map do |sequence|
        (
          shifted_timestamp |
          shifted_logical_shard_id |
          (sequence << Dogtag::SEQUENCE_SHIFT)
        )
      end
    end

    private

    attr_reader :count

    def shifted_timestamp
      timestamp = Timestamp.from_redis(response.seconds, response.microseconds_part)
      timestamp.with_epoch(Dogtag::CUSTOM_EPOCH).milliseconds << Dogtag::TIMESTAMP_SHIFT
    end

    def shifted_logical_shard_id
      response.logical_shard_id << Dogtag::LOGICAL_SHARD_ID_SHIFT
    end

    def response
      @response ||= Request.new(count).response
    end
  end
end
