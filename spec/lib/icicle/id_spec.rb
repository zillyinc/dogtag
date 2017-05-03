require 'spec_helper'
include DummyData

describe Icicle::Id do
  let(:sequence) { 101 }
  let(:logical_shard_id) { 42 }
  let(:now) { Time.now }
  let(:id) { dummy_id(sequence: sequence, logical_shard_id: logical_shard_id, now: now) }
  subject { described_class.new(id) }

  describe '#id' do
    it { expect(subject.id).to eql id }
  end

  describe '#custom_timestamp' do
    it { expect(subject.custom_timestamp).to eql (now.to_f * 1_000).floor - Icicle::CUSTOM_EPOCH }
  end

  describe '#timestamp' do
    it { expect(subject.timestamp).to be_a Icicle::Timestamp }
    it { expect(subject.timestamp.to_i).to eql (now.to_f * 1_000).floor - Icicle::CUSTOM_EPOCH }
    it { expect(subject.timestamp.epoch).to eql Icicle::CUSTOM_EPOCH }
  end

  describe '#logical_shard_id' do
    it { expect(subject.logical_shard_id).to eql logical_shard_id }
  end

  describe '#sequence' do
    it { expect(subject.sequence).to eql sequence }
  end
end
