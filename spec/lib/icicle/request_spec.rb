require 'spec_helper'
include DummyData

describe Icicle::Request do
  let(:count) { 1 }
  let(:lua_script) { 'return "Hello World!"' }
  let(:keys) {
    [
      Icicle::Request::MAX_SEQUENCE,
      Icicle::Request::MIN_LOGICAL_SHARD_ID,
      Icicle::Request::MAX_LOGICAL_SHARD_ID,
      count
    ]
  }
  subject { described_class.new(count) }

  describe '.new' do
    context 'when count is not a number' do
      let(:count) { nil }

      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'when count is zero' do
      let(:count) { 0 }

      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'when count is a negative number' do
      let(:count) { -1 }

      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'when count is a positive number' do
      let(:count) { 1 }

      it { expect { subject }.to_not raise_error }
    end
  end

  describe '#response' do
    context 'when no error is raised' do
      before do
        redis_client = double

        expect(subject).to receive(:lua_script).and_return lua_script
        expect(subject).to receive(:redis).and_return redis_client
        expect(redis_client).to receive(:eval).with(
          lua_script,
          keys: keys
        ).and_return dummy_redis_response(count: count)
      end

      it { expect(subject.response).to be_a Icicle::Response }

      context 'when count is one' do
        it { expect(subject.response.sequence.count).to eql 1 }
      end

      context 'when count is 5' do
        let(:count) { 5 }

        it { expect(subject.response.sequence.count).to eql 5 }
      end
    end

    context 'when a Redis::CommandError is raised' do
      it 'tries up to 5 times' do
        expect(subject).to receive(:redis_response).exactly(5).times.and_raise Redis::CommandError
        expect { subject.response }.to raise_error Redis::CommandError
      end
    end
  end
end
