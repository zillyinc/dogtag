module Dogtag
  class Id
    SEQUENCE_MAP = ~(-1 << Dogtag::SEQUENCE_BITS) << Dogtag::SEQUENCE_SHIFT
    LOGICAL_SHARD_ID_MAP = (~(-1 << Dogtag::LOGICAL_SHARD_ID_BITS)) << Dogtag::LOGICAL_SHARD_ID_SHIFT
    TIMESTAMP_MAP = ~(-1 << Dogtag::TIMESTAMP_BITS) << Dogtag::TIMESTAMP_SHIFT

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def custom_timestamp
      (id & TIMESTAMP_MAP) >> Dogtag::TIMESTAMP_SHIFT
    end

    def timestamp
      @timestamp ||= Timestamp.new(custom_timestamp, epoch: Dogtag::CUSTOM_EPOCH)
    end

    def logical_shard_id
      (id & LOGICAL_SHARD_ID_MAP) >> Dogtag::LOGICAL_SHARD_ID_SHIFT
    end

    def sequence
      (id & SEQUENCE_MAP) >> Dogtag::SEQUENCE_SHIFT
    end
  end
end
