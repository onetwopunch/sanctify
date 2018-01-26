require 'sanctify/matcher'

module Sanctify
  class ParserError < StandardError; end
  class MatcherList
    def initialize(custom_matchers:, disabled_matchers:)
      # initialize Array in case users have that field blank
      @disabled_matchers = disabled_matchers || []
      @custom_matchers = custom_matchers || []

      # Create Matcher objects out of const.
      @matchers = DEFAULT_MATCHERS.map do |obj|
        disabled = @disabled_matchers.include?(obj[:id])
        Matcher.new(obj[:id], obj[:description], obj[:regex], disabled: disabled)
      end
      initialize_custom_matchers!
    end

    def add(id, description, regex)
      if description.empty?
        raise ParserError, "Description must exist and be greater length than zero"
      end

      unless regex.is_a? Regexp
        raise ParserError, "Regex must be of type Regexp"
      end

      @matchers << Matcher.new(id, description, regex)
    end

    def each(&blk)
      @matchers.each &blk
    end

    def initialize_custom_matchers!
      if @custom_matchers.any?
        @custom_matchers.each do |cust|
          if cust['description'] && cust['regex']
            add(cust['id'], cust['description'], Regexp.new(cust['regex']))
          else
            raise ParserError, "Improperly configured custom matcher: #{cust}. Must include 'description' and 'regex'"
          end
        end
      end
    end

    DEFAULT_MATCHERS = [
      {
        id: "aws_access_key_id",
        description: "AWS Access Key ID",
        regex: /AKIA[0-9A-Z]{16}/
      },
      {
        id: "aws_secret_key",
        description: "AWS Secret Key",
        # NOTE: This regex does not match keys that include a /, which is allowed
        # in base64. If we added the slash, there would be many false positives
        # for paths that are exactly 40 characters. PRs welcome if you can figure
        # out a regex that will match base64 but not paths.
        regex: /\b(?<![A-Za-z0-9\/+=])(?=.*[&?=-@#$%\\^+])[A-Za-z0-9\/+=]{40}(?![A-Za-z0-9\/+=])\b/
      },
      {
        id: "ssh_rsa_private_key",
        description: "SSH RSA Private Key",
        regex: /^-----BEGIN RSA PRIVATE KEY-----$/
      },
      {
        id: "x509_certificate",
        description: "X.509 Certificate",
        regex: /^-----BEGIN CERTIFICATE-----$/
      },
      {
        id: "redis_url_with_password",
        description: "Redis URL with Password",
        regex: /redis:\/\/[0-9a-zA-Z:@.\\-]+/
      },
      {
        id: "url_basic_auth",
        description: "URL Basic auth",
        regex: /https?:\/\/[0-9a-zA-z_]+?:[0-9a-zA-z_]+?@.+?/
      },
      {
        id: "google_access_token",
        description:"Google Access Token",
        regex: /ya29.[0-9a-zA-Z_\\-]{68}/
      },
      {
        id: "google_api",
        description: "Google API",
        regex: /AIzaSy[0-9a-zA-Z_\\-]{33}/
      },
      {
        id: "slack_api",
        description: "Slack API",
        regex: /xoxp-\\d+-\\d+-\\d+-[0-9a-f]+/
      },
      {
        id: "slack_bot",
        description: "Slack Bot",
        regex: /xoxb-\\d+-[0-9a-zA-Z]+/
      },
      {
        id: "gem_fury_v1",
        description: "Gem Fury v1",
        regex: /https?:\/\/[0-9a-zA-Z]+@[a-z]+\\.(gemfury.com|fury.io)(\/[a-z]+)?/
      },
      {
        id: "gem_fury_v2",
        description: "Gem Fury v2",
        regex: /https?:\/\/[a-z]+\\.(gemfury.com|fury.io)\/[0-9a-zA-Z]{20}/
      }
    ]
  end
end
