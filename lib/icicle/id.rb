module Icicle
  class Id
    SEQUENCE_MAP = ~(-1 << Icicle::SEQUENCE_BITS) << Icicle::SEQUENCE_SHIFT
    LOGICAL_SHARD_ID_MAP = (~(-1 << Icicle::LOGICAL_SHARD_ID_BITS)) << Icicle::LOGICAL_SHARD_ID_SHIFT
    TIMESTAMP_MAP = ~(-1 << Icicle::TIMESTAMP_BITS) << Icicle::TIMESTAMP_SHIFT

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def custom_timestamp
      (id & TIMESTAMP_MAP) >> Icicle::TIMESTAMP_SHIFT
    end

    def timestamp
      custom_timestamp + Icicle::CUSTOM_EPOCH
    end

    def time
      Time.at(timestamp / Icicle::ONE_SECOND_IN_MILLIS)
    end

    def logical_shard_id
      (id & LOGICAL_SHARD_ID_MAP) >> Icicle::LOGICAL_SHARD_ID_SHIFT
    end

    def sequence
      (id & SEQUENCE_MAP) >> Icicle::SEQUENCE_BITS
    end
  end
end
