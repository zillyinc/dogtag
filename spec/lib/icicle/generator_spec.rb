require 'spec_helper'
include DummyData

describe Icicle::Generator do
  let(:count) { 1 }
  let(:sequence_start) { 99 }
  let(:logical_shard_id) { 42 }
  let(:now) { DateTime.new(2017, 04, 03).to_time }
  let(:redis_response) {
    dummy_redis_response(
      count: count,
      sequence_start: sequence_start,
      logical_shard_id: logical_shard_id,
      now: now
    )
  }
  let(:response) { Icicle::Response.new(redis_response)}
  subject { described_class.new(count) }

  before do
    expect_any_instance_of(Icicle::Request).to receive(:response).and_return response
  end

  describe '#ids' do
    context 'when count is 1' do
      let(:id) { Icicle::Id.new(subject.ids.first) }

      it { expect(subject.ids.length).to eql 1 }
      it { expect(subject.ids.first).to eql 33339683635372131 }
      it { expect(id.sequence).to eql 99 }
      it { expect(id.logical_shard_id).to eql logical_shard_id }
      it { expect(id.timestamp.to_time).to eql now }
    end

    context 'when count is 6' do
      let(:count) { 6 }

      it { expect(subject.ids.length).to eql 6 }
    end
  end
end
