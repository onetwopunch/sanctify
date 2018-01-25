require 'sanctify/matcher_list'
require 'sanctify/repo'

module Sanctify
  class ScannerError < StandardError; end
  class Scanner
    attr_reader :config, :repo, :matcher_list
    def initialize(args)
      @config = args[:config] || {}
      @repo = Repo.new(args, config)
      @matcher_list = MatcherList.new(config)
    end

    def run
      repo.added_lines.each do |line, path|
        matcher_list.each do |matcher|
          next if matcher.disabled?
          if matcher.regex.match(line)
            raise ScannerError, "[ERROR] SECRET FOUND (#{matcher.description}): #{line} : #{path}"
          end
        end
      end
    end
  end
end
