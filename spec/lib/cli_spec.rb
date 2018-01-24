require 'spec_helper'

RSpec.describe Sanctify::CLI, git: true do
  subject { Sanctify::CLI.run(argv) }
  let(:repo) { @path }
  before do
    FileUtils.chdir @path do
      File.open('test', 'a') { |f| f.write("pIW/g216XEHyoF+dIHkYgh439nGko8ga65VTusGF") }
    end
  end
  context 'without config' do
    let(:argv) { ['-r', repo] }
    it 'should raise an error' do
      expect{ subject }.to raise_error(Sanctify::ScannerError)
    end
  end
  context 'with config' do
    let(:argv) { ['-r', repo, '-c', "spec/fixtures/sanctify.yml"] }
    it 'should raise an error' do
      expect{ subject }.not_to raise_error
    end
  end
end
