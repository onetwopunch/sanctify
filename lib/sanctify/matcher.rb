module Sanctify
  class Matcher
    attr_reader :id, :description, :regex
    def initialize(id, description, regex, disabled: false)
      @id = id
      @description = description
      @regex = regex
      @disabled = disabled
    end

    def disabled?
      @disabled
    end
  end
end
