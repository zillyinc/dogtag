require 'spec_helper'

describe Dogtag::LuaScript do
  it 'replaces ERB tags' do
    expect(Dogtag::LuaScript.to_s).to_not match /<%.*%>/
  end

  it 'sets values from Ruby' do
    lua_script = Dogtag::LuaScript.to_s
    expect(lua_script).to match "logical_shard_id_range_key = '#{Dogtag::LOGICAL_SHARD_ID_RANGE_KEY}'"
    expect(lua_script).to match "max_sequence = #{Dogtag::MAX_SEQUENCE}"
  end
end
