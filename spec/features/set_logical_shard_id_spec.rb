require 'spec_helper'
include DummyData
include Dogtag::Mixins::Redis

describe 'Dogtag.logical_shard_id_range=' do
  let(:shard_id_range) { random_logical_shard_id_range }

  before { redis.del Dogtag::LOGICAL_SHARD_ID_RANGE_KEY }

  it 'changes dogtag-generator-logical-shard-id-range in Redis' do
    expect {
      Dogtag.logical_shard_id_range = shard_id_range
    }.to change {
      redis.sort Dogtag::LOGICAL_SHARD_ID_RANGE_KEY
    }.from([]).to [shard_id_range.min.to_s, shard_id_range.max.to_s]
  end
end
