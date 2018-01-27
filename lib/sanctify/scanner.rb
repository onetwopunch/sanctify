require 'sanctify/matcher_list'
require 'sanctify/repo'

module Sanctify
  class ScannerError < StandardError; end
  class Scanner
    attr_reader :repo, :matcher_list
    def initialize(args)
      config = args[:config] || {}
      @repo = Repo.new(args, ignored_paths: config['ignored_paths'])
      @matcher_list = MatcherList.new(
        custom_matchers: config['custom_matchers'],
        disabled_matchers: config['disabled_matchers'])
    end

    def run
      repo.added_lines.each do |line, path|
        matcher_list.each do |matcher|
          next if matcher.disabled?
          if matcher.regex.match(line)
            raise ScannerError, message(matcher, line, path)
          end
        end
      end
    end

    private

    def message(matcher, line, path)
      "[ERROR] SECRET FOUND (#{matcher.description}): #{line} : #{path}"
    end
  end
end
