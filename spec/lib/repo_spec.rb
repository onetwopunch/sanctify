require 'spec_helper'

RSpec.describe Sanctify::Repo, git: true do
  context 'with multiple commits' do
    before do
      FileUtils.chdir @path do
        3.times do |i|
          File.open('test', 'a') { |f| f.write("test#{i}\n") }
          @git.add(all: true)
          @git.commit("Commit #{i}")
        end
        @latest = @git.revparse("HEAD^1")
      end
    end

    subject { Sanctify::Repo.new({repo: @path, from: @initial_commit, to: @latest}) }

    it 'should have include the right commits' do
      expect(subject.added_lines).to eq([["test0", "test"], ["test1", "test"]])
    end
  end
  context 'with cached changes' do
    before do
      FileUtils.chdir @path do
        File.open('test', 'a') { |f| f.write(payload) }
      end
    end
    let(:payload) { "line1\nline2\n"}
    subject { Sanctify::Repo.new({repo: @path}) }

    it 'should have a diff in test' do
      expect(subject.diff.first.path).to eq('test')
    end

    it 'should show sancitfy in the diff' do
      expect(subject.diff.first.patch).to include("+line1\n+line2")
    end

    it 'should include all added lines' do
      expect(subject.added_lines).to eq([['line1', 'test'], ['line2', 'test']])
    end
  end
end
