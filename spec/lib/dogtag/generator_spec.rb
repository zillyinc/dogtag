require 'spec_helper'
include DummyData

describe Dogtag::Generator do
  let(:data_type) { random_data_type }
  let(:count) { 1 }
  let(:sequence_start) { 99 }
  let(:logical_shard_id) { random_logical_shard_id }
  let(:now) { DateTime.new(2017, 04, 03).to_time }
  let(:redis_response) {
    dummy_redis_response(
      count: count,
      sequence_start: sequence_start,
      logical_shard_id: logical_shard_id,
      now: now
    )
  }
  let(:response) { Dogtag::Response.new(redis_response)}
  subject { described_class.new(data_type, count) }

  describe '#ids' do
    context 'when arguments are invalid' do
      context 'when data_type is not an integer' do
        let(:data_type) { 'foo' }
        it { expect { subject }.to raise_error ArgumentError }
      end

      context 'when data_type is less than 0' do
        let(:data_type) { -1 }
        it { expect { subject }.to raise_error ArgumentError }
      end

      context 'when data_type is over the max' do
        let(:data_type) { Dogtag::Generator::MAX_DATA_TYPE + 1 }
        it { expect { subject }.to raise_error ArgumentError }
      end

      context 'when count is not an integer' do
        let(:count) { 'bar' }
        it { expect { subject }.to raise_error ArgumentError }
      end

      context 'when count is a negative number' do
        let(:count) { -1 }
        it { expect { subject }.to raise_error ArgumentError }
      end
    end

    context 'when arguments are valid' do
      before do
        expect_any_instance_of(Dogtag::Request).to receive(:response).and_return response
      end

      context 'when count is 1' do
        let(:id) { Dogtag::Id.new(subject.ids.first) }
        let(:logical_shard_id) { 1 }
        let(:data_type) { 0 }

        it { expect(subject.ids.length).to eql 1 }
        it { expect(subject.ids.first).to eql 66679367271448675 }
        it { expect(id.sequence).to eql 99 }
        it { expect(id.data_type).to eql data_type }
        it { expect(id.logical_shard_id).to eql logical_shard_id }
        it { expect(id.timestamp.to_time).to eql now }
      end

      context 'when count is 6' do
        let(:count) { 6 }

        it { expect(subject.ids.length).to eql 6 }
      end
    end
  end
end
