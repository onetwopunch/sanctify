require 'git'

module Sanctify
  class Repo
    attr_reader :path, :git
    def initialize(args, ignored_paths: [])
      @path = args[:repo]
      @to = args[:to] # The default for `to` in git.diff is nil
      @from = args[:from] || 'HEAD'
      @git = Git.open(path)
      ignored_paths ||= []
      @ignored_paths = ignored_paths.map { |pattern| Regexp.new(pattern) }
    end

    def diff
      # The diff processing is only done in the each method
      # so we'll call this method as a singleton so we don't accidentally
      # do this more than once per instance of the repo.
      @diff ||= git.diff(@from, @to).each.to_a
    end

    def added_lines
      [].tap do |lines|
        diff.each do |f|
          next if f.type == 'deleted'
          next if should_ignore? f.path
          f.patch.split("\n").each do |line|
            # don't include leading '+'
            lines << [line[1..-1], f.path] if added_line? line
          end
        end
      end
    end

    private

    def should_ignore?(path)
      # Add pattern matching for filenames so users can ignore files that
      # they know contain secrets that they have accepted as false positive.
      return false if @ignored_paths.empty?
      @ignored_paths.each do |regex|
        return true if regex.match(path)
      end
      false
    end

    def added_line?(line)
      line.start_with?('+') && !line.start_with?('+++')
    end
  end
end
