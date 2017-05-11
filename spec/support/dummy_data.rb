module DummyData
  def random_logical_shard_id
    rand(Dogtag::MIN_LOGICAL_SHARD_ID..Dogtag::MAX_LOGICAL_SHARD_ID)
  end

  def random_logical_shard_id_range
    min = random_logical_shard_id
    min..rand(min..Dogtag::MAX_LOGICAL_SHARD_ID)
  end

  def random_data_type
    rand(0..(~(-1 << Dogtag::DATA_TYPE_BITS)))
  end

  def dummy_redis_response(count: nil, sequence_start: nil, logical_shard_id: nil, now: nil)
    count ||= 1
    logical_shard_id ||= random_logical_shard_id
    now ||= Time.now

    @sequence = (sequence_start - 1) unless sequence_start.nil?

    if @sequence.nil? || @sequence >= Dogtag::MAX_SEQUENCE
      @sequence = -1
    end

    @sequence += count
    start_sequence = @sequence - count + 1

    if @sequence >= Dogtag::MAX_SEQUENCE
      @sequence = Dogtag::MAX_SEQUENCE
    end

    [
      start_sequence,
      @sequence,
      logical_shard_id,
      now.to_i,
      now.usec
    ]
  end

  def dummy_id(sequence: nil, data_type: nil, logical_shard_id: nil, now: nil)
    sequence ||= 0
    data_type ||= random_data_type
    logical_shard_id ||= random_logical_shard_id
    now ||= Time.now
    timestamp = Dogtag::Timestamp.from_redis(now.to_i, now.usec).with_epoch(Dogtag::CUSTOM_EPOCH)

    (
      (timestamp.milliseconds << Dogtag::TIMESTAMP_SHIFT) |
      (logical_shard_id << Dogtag::LOGICAL_SHARD_ID_SHIFT) |
      (data_type << Dogtag::DATA_TYPE_SHIFT) |
      (sequence << Dogtag::SEQUENCE_SHIFT)
    )
  end
end
