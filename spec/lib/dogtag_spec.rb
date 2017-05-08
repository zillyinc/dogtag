require 'spec_helper'
include DummyData

describe Dogtag do
  subject { described_class }

  describe '.logical_shard_id=' do
    let(:logical_shard_id) { 42 }

    it 'sets the logical_shard_id in Redis' do
      redis_client = double
      expect(subject).to receive(:redis).and_return redis_client
      expect(redis_client).to receive(:set).with(Dogtag::LOGICAL_SHARD_ID_KEY, logical_shard_id)

      subject.logical_shard_id= logical_shard_id
    end
  end

  describe '.generate_id' do
    let(:id) { dummy_id }
    let(:ids) { [id] }

    it 'generates one ID' do
      expect_any_instance_of(Dogtag::Generator).to receive(:ids).and_return ids
      expect(subject.generate_id).to eql id
    end
  end

  describe '.generate_ids' do
    let(:count) { 1 }
    let(:ids) { count.times.map { dummy_id } }

    context 'when count is one' do
      it 'generates one ID' do
        expect_any_instance_of(Dogtag::Generator).to receive(:ids).and_return ids
        expect(subject.generate_ids(count)).to eql ids
      end
    end

    context 'when count is seven' do
      let(:count) { 7 }

      it 'generates seven ID' do
        expect_any_instance_of(Dogtag::Generator).to receive(:ids).and_return ids
        expect(subject.generate_ids(count)).to eql ids
      end
    end
  end
end
