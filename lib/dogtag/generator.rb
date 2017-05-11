module Dogtag
  class Generator
    def initialize(data_type, count = 1)
      unless data_type.is_a? Integer
        raise ArgumentError, 'data_type must be an integer'
      end

      unless Dogtag::DATA_TYPE_ALLOWED_RANGE.include? data_type
        raise ArgumentError, "data_type is outside the allowed range of #{Dogtag::DATA_TYPE_ALLOWED_RANGE}"
      end

      raise ArgumentError, 'count must be an integer' unless count.is_a? Integer
      raise ArgumentError, 'count must be a positive number' if count < 1

      @data_type = data_type
      @count = count
    end

    def ids
      response.sequence.map do |sequence|
        (
          shifted_timestamp |
          shifted_logical_shard_id |
          shifted_data_type |
          (sequence << Dogtag::SEQUENCE_SHIFT)
        )
      end
    end

    private

    attr_reader :data_type, :count

    def shifted_timestamp
      timestamp = Timestamp.from_redis(response.seconds, response.microseconds_part)
      timestamp.with_epoch(Dogtag::CUSTOM_EPOCH).milliseconds << Dogtag::TIMESTAMP_SHIFT
    end

    def shifted_data_type
      data_type << Dogtag::DATA_TYPE_SHIFT
    end

    def shifted_logical_shard_id
      response.logical_shard_id << Dogtag::LOGICAL_SHARD_ID_SHIFT
    end

    def response
      @response ||= Request.new(data_type, count).response
    end
  end
end
