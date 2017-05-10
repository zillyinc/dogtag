require 'spec_helper'
include DummyData

describe Dogtag::Id do
  let(:sequence) { 101 }
  let(:data_type) { random_data_type }
  let(:logical_shard_id) { random_logical_shard_id }
  let(:now) { Time.now }
  let(:id) { dummy_id(sequence: sequence, data_type: data_type, logical_shard_id: logical_shard_id, now: now) }
  subject { described_class.new(id) }

  describe '#id' do
    it { expect(subject.id).to eql id }
  end

  describe '#custom_timestamp' do
    it { expect(subject.custom_timestamp).to eql (now.to_f * 1_000).floor - Dogtag::CUSTOM_EPOCH }
  end

  describe '#timestamp' do
    it { expect(subject.timestamp).to be_a Dogtag::Timestamp }
    it { expect(subject.timestamp.to_i).to eql (now.to_f * 1_000).floor - Dogtag::CUSTOM_EPOCH }
    it { expect(subject.timestamp.epoch).to eql Dogtag::CUSTOM_EPOCH }
  end

  describe '#logical_shard_id' do
    it { expect(subject.logical_shard_id).to eql logical_shard_id }
  end

  describe '#data_type' do
    it { expect(subject.data_type).to eql data_type }
  end

  describe '#sequence' do
    it { expect(subject.sequence).to eql sequence }
  end
end
