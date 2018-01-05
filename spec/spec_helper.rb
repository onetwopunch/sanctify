require "bundler/setup"
require "sanctify"
require "git"
require "pry"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :all, git: true do
    @path = "tmp/test_repo"
    FileUtils.mkdir_p(@path)
    FileUtils.cd(@path) do
      @git = Git.init
      File.open('test', 'w') do |f|
        f.write("Hello World\n")
      end
      @git.add("test")
      @git.commit("Initial Commit")
      @initial_commit = @git.revparse('HEAD')
    end
  end

  config.after :each, git: true do
    @git.reset_hard(@initial_commit)
  end

  config.after :all, git: true do
    # This method introduces a security hole under certain conditions
    # read for more info: http://ruby-doc.org/stdlib-2.4.2/libdoc/fileutils/rdoc/FileUtils.html#method-c-rm_r
    FileUtils.rm_rf @path
  end
end
