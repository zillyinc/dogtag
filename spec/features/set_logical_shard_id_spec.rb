require 'spec_helper'
include Icicle::Mixins::Redis

describe 'Icicle.logical_shard_id=' do
  let(:shard_id) { rand(0..Icicle::Request::MAX_LOGICAL_SHARD_ID) }

  before { redis.del Icicle::LOGICAL_SHARD_ID_KEY }

  it 'changes icicle-generator-logical-shard-id in Redis' do
    expect {
      Icicle.logical_shard_id = shard_id
    }.to change {
      redis.get Icicle::LOGICAL_SHARD_ID_KEY
    }.from(nil).to shard_id.to_s
  end
end
