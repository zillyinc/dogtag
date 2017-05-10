require 'spec_helper'
include DummyData

describe Dogtag do
  let(:data_type) { random_data_type }
  subject { described_class }

  describe '.logical_shard_id=' do
    let(:logical_shard_id) { random_logical_shard_id }

    context 'when logical_shard_id is not an Integer' do
      let(:logical_shard_id) { 'WAT' }
      it { expect { subject.logical_shard_id = logical_shard_id }.to raise_error ArgumentError }
    end

    context 'when logical_shard_id is less than 0' do
      let(:logical_shard_id) { -1 }
      it { expect { subject.logical_shard_id = logical_shard_id }.to raise_error ArgumentError }
    end

    context 'when logical_shard_id is more than the max' do
      let(:logical_shard_id) { Dogtag::Request::MAX_LOGICAL_SHARD_ID + 1 }
      it { expect { subject.logical_shard_id = logical_shard_id }.to raise_error ArgumentError }
    end

    it 'sets the logical_shard_id in Redis' do
      redis_client = double
      expect(subject).to receive(:redis).and_return redis_client
      expect(redis_client).to receive(:set).with(Dogtag::LOGICAL_SHARD_ID_KEY, logical_shard_id)

      subject.logical_shard_id = logical_shard_id
    end
  end

  describe '.generate_id' do
    let(:id) { dummy_id }
    let(:ids) { [id] }

    it 'generates one ID' do
      expect_any_instance_of(Dogtag::Generator).to receive(:ids).and_return ids
      expect(subject.generate_id(data_type)).to eql id
    end
  end

  describe '.generate_ids' do
    let(:count) { 1 }
    let(:ids) { count.times.map { dummy_id } }

    context 'when count is one' do
      it 'generates one ID' do
        expect_any_instance_of(Dogtag::Generator).to receive(:ids).and_return ids
        expect(subject.generate_ids(data_type, count)).to eql ids
      end
    end

    context 'when count is seven' do
      let(:count) { 7 }

      it 'generates seven ID' do
        expect_any_instance_of(Dogtag::Generator).to receive(:ids).and_return ids
        expect(subject.generate_ids(data_type, count)).to eql ids
      end
    end
  end
end
