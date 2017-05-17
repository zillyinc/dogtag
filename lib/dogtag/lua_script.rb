require 'erb'

module Dogtag
  module LuaScript
    LUA_SCRIPT_PATH = 'lua/id-generation.lua.erb'.freeze

    def self.to_s
      @rendered_script ||= ERB.new(
        File.read(
          File.expand_path "../../#{LUA_SCRIPT_PATH}", File.dirname(__FILE__)
        )
      ).result
    end
  end
end
