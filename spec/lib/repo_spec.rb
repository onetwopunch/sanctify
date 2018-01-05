require 'spec_helper'

RSpec.describe Sanctify::Repo, git: true do
  subject { Sanctify::Repo.new(@path) }
  let(:payload) { "line1\nline2\n"}
  before do
    FileUtils.chdir @path do
      File.open('test', 'a') { |f| f.write(payload) }
    end
  end

  context 'with cached changes' do
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
