require 'sanctify/matcher'

module Sanctify
  class ParserError < StandardError; end
  class MatcherList
    attr_reader :config
    def initialize(config)
      @matchers = DEFAULT_MATCHERS.map{ |obj| Matcher.new(obj[:description], obj[:regex], config) }
      @config = config
      initialize_custom_matchers!
    end

    def add(description, regex)
      if description.length.zero?
        raise ParserError, "Description must exist and be greater length than zero"
      end

      unless regex.is_a? Regexp
        raise ParserError, "Regex must be of type Regexp"
      end

      @matchers << Matcher.new(description, regex, config)
      @matchers
    end

    def each(&blk)
      @matchers.each &blk
    end

    def initialize_custom_matchers!
      custom_matchers = config['custom_matchers'] || []
      if custom_matchers.any?
        custom_matchers.each do |cust|
          if cust['description'] && cust['regex']
            add(cust['description'], Regexp.new(cust['regex']))
          else
            raise ParserError, "Improperly configured custom matcher: #{cust}. Must include 'description' and 'regex'"
          end
        end
      end
    end

    DEFAULT_MATCHERS = [
      {
        description: "AWS Access Key ID",
        regex: /AKIA[0-9A-Z]{16}/
      },
      {
        description: "AWS Secret Key",
        # NOTE: This regex does not match keys that include a /, which is allowed
        # in base64. If we added the slash, there would be many false positives
        # for paths that are exactly 40 characters. PRs welcome if you can figure
        # out a regex that will match base64 but not paths.
        regex: /\b(?<![A-Za-z0-9\/+=])(?=.*[&?=-@#$%\\^+])[A-Za-z0-9\/+=]{40}(?![A-Za-z0-9\/+=])\b/
      },
      {
        description: "SSH RSA Private Key",
        regex: /^-----BEGIN RSA PRIVATE KEY-----$/
      },
      {
        description: "X509 Certificate",
        regex: /^-----BEGIN CERTIFICATE-----$/
      },
      {
        description: "Redis URL with Password",
        regex: /redis:\/\/[0-9a-zA-Z:@.\\-]+/
      },
      {
        description: "URL Basic auth",
        regex: /https?:\/\/[0-9a-zA-z_]+?:[0-9a-zA-z_]+?@.+?/
      },
      {
        description:"Google Access Token",
        regex: /ya29.[0-9a-zA-Z_\\-]{68}/
      },
      {
        description: "Google API",
        regex: /AIzaSy[0-9a-zA-Z_\\-]{33}/
      },
      {
        description: "Slack API",
        regex: /xoxp-\\d+-\\d+-\\d+-[0-9a-f]+/
      },
      {
        description: "Slack Bot",
        regex: /xoxb-\\d+-[0-9a-zA-Z]+/
      },
      {
        description: "Gem Fury v1",
        regex: /https?:\/\/[0-9a-zA-Z]+@[a-z]+\\.(gemfury.com|fury.io)(\/[a-z]+)?/
      },
      {
        description: "Gem Fury v2",
        regex: /https?:\/\/[a-z]+\\.(gemfury.com|fury.io)\/[0-9a-zA-Z]{20}/
      }
    ]
  end
end
