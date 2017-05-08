require 'spec_helper'

describe 'Dogtag.generate_id' do
  let(:shard_id) { rand(0..Dogtag::Request::MAX_LOGICAL_SHARD_ID) }
  let(:id) { Dogtag::Id.new(subject) }

  subject { Dogtag.generate_id }

  it 'returns a new ID' do
    expect(subject).to be_a Numeric
  end

  it 'increases with each call' do
    expect(subject).to be < Dogtag.generate_id
  end

  it 'contains a current timestamp' do
    expect(id.timestamp.to_time).to be_between (Time.now - 1), (Time.now + 1)
  end

  it 'contains the logical shard ID' do
    Dogtag.logical_shard_id = shard_id

    expect(id.logical_shard_id).to eql shard_id
  end

  it 'contains a sequence' do
    expect(id.sequence).to be_a Numeric
    expect(id.sequence).to be_between 0, Dogtag::Request::MAX_SEQUENCE
    expect(id.sequence).to be < Dogtag::Id.new(Dogtag.generate_id).sequence
  end
end
