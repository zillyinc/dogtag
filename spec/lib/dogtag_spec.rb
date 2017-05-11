require 'spec_helper'
include DummyData

describe Dogtag do
  let(:data_type) { random_data_type }
  subject { described_class }

  describe '.logical_shard_id_range=' do
    let(:logical_shard_id_range) { random_logical_shard_id_range }

    context 'when logical_shard_id_range is not a Range' do
      let(:logical_shard_id_range) { 'WAT' }
      it { expect { subject.logical_shard_id_range = logical_shard_id_range }.to raise_error ArgumentError }
    end

    context 'when logical_shard_id_range is outside the allowed range' do
      let(:logical_shard_id_range) { random_logical_shard_id..(Dogtag::MAX_LOGICAL_SHARD_ID + 1) }
      it { expect { subject.logical_shard_id_range = logical_shard_id_range }.to raise_error ArgumentError }
    end

    context 'when arguments are valid' do
      let(:redis_client) { double }
      let(:exists) { false }

      before do
        allow(subject).to receive(:redis).and_return redis_client
        expect(redis_client).to receive(:exists).with(Dogtag::LOGICAL_SHARD_ID_RANGE_KEY).and_return exists
      end

      context "when logical_shard_id_range doesn't exist" do
        it 'creates the logical_shard_id_range in Redis' do
          expect(redis_client).to receive(:rpush).with Dogtag::LOGICAL_SHARD_ID_RANGE_KEY, logical_shard_id_range.min
          expect(redis_client).to receive(:rpush).with Dogtag::LOGICAL_SHARD_ID_RANGE_KEY, logical_shard_id_range.max

          subject.logical_shard_id_range = logical_shard_id_range
        end
      end

      context "when logical_shard_id_range already exists" do
        let(:exists) { true }

        it 'overwrites the logical_shard_id_range in Redis' do
          expect(redis_client).to receive(:lset).with Dogtag::LOGICAL_SHARD_ID_RANGE_KEY, 0, logical_shard_id_range.min
          expect(redis_client).to receive(:lset).with Dogtag::LOGICAL_SHARD_ID_RANGE_KEY, 1, logical_shard_id_range.max

          subject.logical_shard_id_range = logical_shard_id_range
        end
      end
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
