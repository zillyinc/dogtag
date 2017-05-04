require 'spec_helper'

describe 'Icicle.generate_id' do
  let(:shard_id) { rand(0..Icicle::Request::MAX_LOGICAL_SHARD_ID) }
  let(:id) { Icicle::Id.new(subject) }

  subject { Icicle.generate_id }

  it 'returns a new ID' do
    expect(subject).to be_a Numeric
  end

  it 'increases with each call' do
    expect(subject).to be < Icicle.generate_id
  end

  it 'contains a current timestamp' do
    expect(id.timestamp.to_time).to be_between (Time.now - 1), (Time.now + 1)
  end

  it 'contains the logical shard ID' do
    Icicle.logical_shard_id = shard_id

    expect(id.logical_shard_id).to eql shard_id
  end

  it 'contains a sequence' do
    expect(id.sequence).to be_a Numeric
    expect(id.sequence).to be_between 0, Icicle::Request::MAX_SEQUENCE
    expect(id.sequence).to be < Icicle::Id.new(Icicle.generate_id).sequence
  end
end
