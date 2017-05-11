require 'spec_helper'

describe 'Dogtag.generate_ids' do
  let(:data_type) { random_data_type }
  let(:count) { 3 }
  let(:ids) { subject.map { |id| Dogtag::Id.new(id) } }

  subject { Dogtag.generate_ids(data_type, count) }

  it 'returns new IDs' do
    expect(subject).to all be_a Numeric
    expect(subject.length).to eql count
  end

  it 'increases with each call' do
    expect(subject).to eql subject.sort
  end

  it 'contains a current timestamp' do
    expect(ids.map(&:timestamp)).to all be_a Dogtag::Timestamp
    expect(ids.map(&:custom_timestamp)).to all be_between 0, ~(-1 << Dogtag::TIMESTAMP_BITS)
    expect(ids.map(&:timestamp).map(&:to_time)).to all be_between (Time.now - 1), (Time.now + 1)
  end

  context 'when logical_shard_id_range is a range' do
    let(:shard_id_range) { random_logical_shard_id_range }

    it 'contains one of the logical shard IDs' do
      Dogtag.logical_shard_id_range = shard_id_range

      expect(ids.map(&:logical_shard_id)).to all be_a Numeric
      expect(ids.map(&:logical_shard_id)).to all be_between Dogtag::MIN_LOGICAL_SHARD_ID, Dogtag::MAX_LOGICAL_SHARD_ID
      expect(ids.map(&:logical_shard_id)).to all be_between shard_id_range.min, shard_id_range.max
    end
  end

  context 'when logical_shard_id_range is one number' do
    let(:shard_id) { random_logical_shard_id }

    it 'contains the logical shard ID' do
      Dogtag.logical_shard_id_range = shard_id..shard_id

      expect(ids.map(&:logical_shard_id)).to all be_a Numeric
      expect(ids.map(&:logical_shard_id)).to all be_between Dogtag::MIN_LOGICAL_SHARD_ID, Dogtag::MAX_LOGICAL_SHARD_ID
      expect(ids.map(&:logical_shard_id)).to all eql shard_id
    end
  end

  it 'contains a sequence' do
    expect(ids.map(&:sequence)).to all be_a Numeric
    expect(ids.map(&:sequence)).to all be_between 0, Dogtag::MAX_SEQUENCE
    expect(ids.map(&:sequence)).to eql ids.map(&:sequence).sort
  end

  context 'when count is more than the Lua script can return in one shot' do
    let(:count) { Dogtag::MAX_SEQUENCE + 100 }

    it 'generates the requested amount of IDs' do
      expect(subject.length).to eql count
    end
  end
end
