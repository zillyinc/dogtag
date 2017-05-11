require 'spec_helper'
include DummyData
include Dogtag::Mixins::Redis

describe 'Dogtag.logical_shard_id=' do
  let(:shard_id) { random_logical_shard_id }

  before { redis.del Dogtag::LOGICAL_SHARD_ID_KEY }

  it 'changes dogtag-generator-logical-shard-id in Redis' do
    expect {
      Dogtag.logical_shard_id = shard_id
    }.to change {
      redis.get Dogtag::LOGICAL_SHARD_ID_KEY
    }.from(nil).to shard_id.to_s
  end
end
