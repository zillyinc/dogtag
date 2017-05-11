require 'spec_helper'
include DummyData

describe 'Dogtag.generate_id' do
  let(:data_type) { random_data_type }
  let(:shard_id) { random_logical_shard_id }
  let(:id) { Dogtag::Id.new(subject) }

  subject { Dogtag.generate_id(data_type) }

  it 'returns a new ID' do
    expect(subject).to be_a Numeric
  end

  it 'increases with each call' do
    expect(subject).to be < Dogtag.generate_id(data_type)
  end

  it 'contains a current timestamp' do
    expect(id.timestamp).to be_a Dogtag::Timestamp
    expect(id.custom_timestamp).to be_between 0, ~(-1 << Dogtag::TIMESTAMP_BITS)
    expect(id.timestamp.to_time).to be_between (Time.now - 1), (Time.now + 1)
  end

  it 'contains the logical shard ID' do
    Dogtag.logical_shard_id = shard_id

    expect(id.logical_shard_id).to be_a Numeric
    expect(id.logical_shard_id).to be_between Dogtag::MIN_LOGICAL_SHARD_ID, Dogtag::MAX_LOGICAL_SHARD_ID
    expect(id.logical_shard_id).to eql shard_id
  end

  it 'contains the data type' do
    expect(id.data_type).to be_a Numeric
    expect(id.data_type).to be_between 0, ~(-1 << Dogtag::DATA_TYPE_BITS)
    expect(id.data_type).to eql data_type
  end

  it 'contains a sequence' do
    expect(id.sequence).to be_a Numeric
    expect(id.sequence).to be_between 0, Dogtag::MAX_SEQUENCE
    expect(id.sequence).to be < Dogtag::Id.new(Dogtag.generate_id(data_type)).sequence
  end
end
