require 'spec_helper'

describe 'Icicle.generate_ids' do
  let(:shard_id) { rand(0..Icicle::Request::MAX_LOGICAL_SHARD_ID) }
  let(:count) { 3 }
  let(:ids) { subject.map { |id| Icicle::Id.new(id) } }

  subject { Icicle.generate_ids(count) }

  it 'returns new IDs' do
    expect(subject).to all be_a Numeric
    expect(subject.length).to eql count
  end

  it 'increases with each call' do
    expect(subject).to eql subject.sort
  end

  it 'contains a current timestamp' do
    expect(ids.map(&:timestamp).map(&:to_time)).to all be_between (Time.now - 1), (Time.now + 1)
  end

  it 'contains the logical shard ID' do
    Icicle.logical_shard_id = shard_id

    expect(ids.map(&:logical_shard_id)).to all eql shard_id
  end

  it 'contains a sequence' do
    expect(ids.map(&:sequence)).to all be_a Numeric
    expect(ids.map(&:sequence)).to all be_between 0, Icicle::Request::MAX_SEQUENCE
    expect(ids.map(&:sequence)).to eql ids.map(&:sequence).sort
  end

  context 'when count is more than the Lua script can return in one shot' do
    let(:count) { Icicle::Request::MAX_SEQUENCE + 100 }

    it 'generates the requested amount of IDs' do
      expect(subject.length).to eql count
    end
  end
end
