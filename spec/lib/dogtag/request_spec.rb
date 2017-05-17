require 'spec_helper'
include DummyData

describe Dogtag::Request do
  let(:data_type) { random_data_type }
  let(:count) { 1 }
  let(:lua_script) { 'return "Hello World!"' }
  let(:keys) { [ data_type, count ] }
  subject { described_class.new(data_type, count) }

  describe '.new' do
    context 'when data_type is not a number' do
      let(:data_type) { nil }

      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'when data_type is a negative number' do
      let(:data_type) { -1 }

      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'when data_type is outside the allowed range' do
      let(:data_type) { Dogtag::MAX_DATA_TYPE + 1 }

      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'when data_type is within the allowed range' do
      let(:data_type) { random_data_type }

      it { expect { subject }.to_not raise_error }
    end

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

        expect(subject).to receive(:redis).and_return redis_client
        expect(subject).to receive(:lua_script_sha).and_return 'dummysha'
        expect(redis_client).to receive(:evalsha).with(
          'dummysha',
          keys: keys
        ).and_return dummy_redis_response(count: count)
      end

      it { expect(subject.response).to be_a Dogtag::Response }

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
