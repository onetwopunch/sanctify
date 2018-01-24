require 'sanctify/matcher_list'
require 'sanctify/repo'

module Sanctify
  class ScannerError < StandardError; end
  class Scanner
    attr_reader :config, :repo, :matcher_list
    def initialize(args)
      @config = args[:config] || {}
      @repo = Repo.new(args, ignored_paths)
      @matcher_list = MatcherList.new
    end

    def run
      initialize_custom_matchers!
      repo.added_lines.each do |line, path|
        matcher_list.each do |matcher|
          if matcher[:regex].match(line)
            raise ScannerError, "[ERROR] SECRET FOUND (#{matcher[:description]}): #{line} : #{path}"
          end
        end
      end
    end

    private

    def ignored_paths
      patterns = config['ignored_paths'] || []
      patterns.map { |patt| Regexp.new patt }
    end

    def initialize_custom_matchers!
      custom_matchers = config['custom_matchers'] || []
      if custom_matchers.any?
        custom_matchers.each do |cust|
          if cust['description'] && cust['regex']
            matcher_list.add(desc: cust['description'], regex: Regexp.new(cust['regex']))
          else
            raise ScannerError, "Improperly configured custom matcher: #{cust}. Must include 'description' and 'regex'"
          end
        end
      end
    end
  end
end
