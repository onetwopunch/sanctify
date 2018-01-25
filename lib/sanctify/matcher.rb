module Sanctify
  class Matcher
    attr_reader :description, :regex, :config
    def initialize(description, regex, config)
      @description = description
      @regex = regex
      @config = config
    end

    def id
      description.downcase.gsub(' ', '_')
    end

    def disabled?
      # NOTE: Allow users to specify entire description or something like it.
      # For example, this would allow a user to disable matchers with description:
      #
      disabled_matchers = config['disabled_matchers'] || []
      disabled_matchers.each do |dis|
        if dis == id
          return true
        end
      end
      return false
    end
  end
end
