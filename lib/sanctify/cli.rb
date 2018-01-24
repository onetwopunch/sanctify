require 'yaml'
require 'optparse'
module Sanctify
  class CliError < StandardError; end
  class CLI
    def self.run(argv)
      args = {}

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: sanctify [-r REPO_PATH] [-c CONFIG_PATH] [--diff FROM_COMMIT..TO_COMMIT | --diff FROM_COMMIT]"

        opts.on("-r REPO", "--repo REPO", "Repo to test") do |repo|
          args[:repo] = repo
        end

        opts.on("-c CONFIG", "--config CONFIG", "Configuration file in YAML") do |config|
          args[:config] = YAML.load(File.open(config.chomp))
        end

        opts.on("-d DIFF", "--diff DIFF", "Specify a diff or commit from which to check secrets") do |diff|
          from, to = diff.split('..')
          args[:from] = from
          args[:to] = to
        end
        opts.on("-v", "--version", "Prints the version and exits") do
          puts "sanctify #{VERSION}"
          exit
        end
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end

      opt_parser.parse!(argv)
      if args[:repo].nil?
        repo = `git rev-parse --show-toplevel`.chomp
        if repo.empty?
          raise Sanctify::CliError, "Repo not specified and current directory not a git repository."
        else
          args[:repo] = repo
        end
      end
      Scanner.new(args).run
      puts "SUCCESS! No Secrets Found in #{args[:repo]}"
    end
  end
end
