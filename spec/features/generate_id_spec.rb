require 'spec_helper'
include DummyData

describe 'Dogtag.generate_id' do
  let(:shard_id_range) { random_logical_shard_id_range }
  let(:data_type) { random_data_type }
  let(:id) { Dogtag::Id.new(subject) }

  subject { Dogtag.generate_id(data_type) }

  before { Dogtag.logical_shard_id_range = shard_id_range }

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

  context 'when logical_shard_id_range is a range' do
    it 'contains one of the logical shard IDs' do
      expect(id.logical_shard_id).to be_a Numeric
      expect(id.logical_shard_id).to be_between Dogtag::MIN_LOGICAL_SHARD_ID, Dogtag::MAX_LOGICAL_SHARD_ID
      expect(id.logical_shard_id).to be_between shard_id_range.min, shard_id_range.max
    end
  end

  context 'when logical_shard_id_range is one number' do
    let(:shard_id) { random_logical_shard_id }
    let(:shard_id_range) { shard_id..shard_id }

    it 'contains the logical shard ID' do
      expect(id.logical_shard_id).to be_a Numeric
      expect(id.logical_shard_id).to be_between Dogtag::MIN_LOGICAL_SHARD_ID, Dogtag::MAX_LOGICAL_SHARD_ID
      expect(id.logical_shard_id).to eql shard_id
    end
  end

  it 'contains the data type' do
    expect(id.data_type).to be_a Numeric
    expect(id.data_type).to be_between 0, ~(-1 << Dogtag::DATA_TYPE_BITS)
    expect(id.data_type).to eql data_type
  end

  it 'contains a sequence' do
    expect(id.sequence).to be_a Numeric
    expect(id.sequence).to be_between 0, Dogtag::MAX_SEQUENCE
  end

  context 'when the Redis server has more than one logical shard ID' do
    let(:shard_id_range) { 1..2 }
    subject { 10.times.map { Dogtag::Id.new(Dogtag.generate_id(data_type)) } }

    it 'uses all logical shard IDs' do
      ones = subject.select { |id| id.logical_shard_id == 1 }
      twos = subject.select { |id| id.logical_shard_id == 2 }

      expect(ones.length).to eql twos.length
    end

    it 'increments the per-shard sequence' do
      shard_id_range.to_a.each do |shard_id|
        shard_sequences = subject.select { |id| id.logical_shard_id == shard_id }.map(&:sequence)
        expect(shard_sequences).to eql shard_sequences.sort
      end
    end
  end
end
