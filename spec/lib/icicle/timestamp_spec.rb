require 'spec_helper'

describe Icicle::Timestamp do
  let(:now) { Time.now }
  let(:milliseconds) { (now.to_f * 1_000).floor }
  let(:epoch) { (DateTime.new(now.year, 1, 1).to_time.to_f * 1_000).floor }
  subject { Icicle::Timestamp.new(milliseconds, epoch: epoch) }

  describe '#milliseconds' do
    it { expect(subject.milliseconds).to eql milliseconds }
  end

  describe '#epoch' do
    it { expect(subject.epoch).to eql epoch }
  end

  describe '#seconds' do
    it { expect(subject.seconds).to eql (milliseconds / 1_000).floor }
  end

  describe '#microseconds_part' do
    let(:milliseconds) { 1491177600000 + 42 }
    it { expect(subject.microseconds_part).to eql 42000 }
  end

  describe '#to_i' do
    it { expect(subject.to_i).to eql milliseconds }
  end

  describe '#to_time' do
    context 'with unix epoch' do
      let(:milliseconds) { 1491177600000 }
      let(:epoch) { 0 }

      it { expect(subject.to_time).to eql DateTime.new(2017, 04, 03).to_time }
    end

    context 'with custom epoch' do
      let(:milliseconds) { 7948800000 }
      let(:epoch) { 1483228800000 }

      it { expect(subject.to_time).to eql DateTime.new(2017, 04, 03).to_time }
    end
  end

  describe '#with_unix_epoch' do
    context 'when epoch is already unix' do
      let(:milliseconds) { 1491177600000 }
      let(:epoch) { 0 }

      it { expect(subject.with_unix_epoch.milliseconds).to eql milliseconds }
    end

    context 'when epoch is custom' do
      let(:milliseconds) { 7948800000 }
      let(:epoch) { 1483228800000 }

      it { expect(subject.with_unix_epoch.milliseconds).to eql 1491177600000 }
    end
  end

  describe '#with_epoch' do
    context 'when epoch is unix' do
      let(:epoch) { 0 }

      context 'when new epoch is unix' do
        let(:new_epoch) { 0 }

        it { expect(subject.with_epoch(new_epoch).milliseconds).to eql milliseconds}
      end

      context 'when new epoch is custom' do
        let(:new_epoch) { 1451606400000 }
        it { expect(subject.with_epoch(new_epoch).to_time.to_i).to eql now.to_i }
      end
    end

    context 'when epoch is custom' do
      let(:milliseconds) { 7948800000 }
      let(:epoch) { 1483228800000 }

      it { expect(subject.with_unix_epoch.milliseconds).to eql 1491177600000 }
    end
  end

  describe '.from_reids' do
    let(:seconds) { 7948800 }
    let(:microseconds_part) { 42000 }
    subject { described_class.from_redis(seconds, microseconds_part) }

    it { expect(subject.milliseconds).to eql 7948800042 }
  end
end
