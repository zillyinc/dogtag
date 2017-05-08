module DummyData
  def dummy_redis_response(count: nil, sequence_start: nil, logical_shard_id: nil, now: nil)
    count ||= 1
    logical_shard_id ||= rand(1..Dogtag::Request::MAX_LOGICAL_SHARD_ID)
    now ||= Time.now

    @sequence = (sequence_start - 1) unless sequence_start.nil?

    if @sequence.nil? || @sequence >= Dogtag::Request::MAX_SEQUENCE
      @sequence = -1
    end

    @sequence += count
    start_sequence = @sequence - count + 1

    if @sequence >= Dogtag::Request::MAX_SEQUENCE
      @sequence = Dogtag::Request::MAX_SEQUENCE
    end

    [
      start_sequence,
      @sequence,
      logical_shard_id,
      now.to_i,
      now.usec
    ]
  end

  def dummy_id(sequence: nil, logical_shard_id: nil, now: nil)
    sequence ||= 0
    logical_shard_id ||= rand(1..Dogtag::Request::MAX_LOGICAL_SHARD_ID)
    now ||= Time.now
    timestamp = Dogtag::Timestamp.from_redis(now.to_i, now.usec).with_epoch(Dogtag::CUSTOM_EPOCH)

    (
      (timestamp.milliseconds << Dogtag::TIMESTAMP_SHIFT) |
      (logical_shard_id << Dogtag::LOGICAL_SHARD_ID_SHIFT) |
      (sequence << Dogtag::SEQUENCE_SHIFT)
    )
  end
end
