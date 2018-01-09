require 'spec_helper'

RSpec.describe Sanctify::Scanner, git: true do
  let(:payload) { "" }

  before do
    FileUtils.chdir @path do
      File.open('test', 'a') { |f| f.write(payload) }
    end
  end
  context 'without config' do
    subject { Sanctify::Scanner.new({repo: @path}).run }

    context 'with AWS Access Key' do
      let(:payload) { "AKIASECRET123456789Z" }
      it 'raises an error' do
        expect{ subject }.to raise_error(Sanctify::ScannerError)
      end
    end

    context 'with AWS Secret Key', focus: true do
      let(:payload) { "pIW/g216XEHyoF+dIHkYgh439nGko8ga65VTusGF" }
      it 'raises an error' do
        expect{ subject }.to raise_error(Sanctify::ScannerError)
      end
    end

    context 'with git sha', focus: true do
      let(:payload) { "a74e98e6c224a9d2dba20c858009a4cb51689822" }
      it 'raises an error' do
        expect{ subject }.not_to raise_error
      end
    end

    context 'with AWS Secret Key', focus: true do
      let(:payload) { "pIW/g216XEHyoF+dIHkYgh439nGko8ga65VTusGF" }
      it 'raises an error' do
        expect{ subject }.to raise_error(Sanctify::ScannerError)
      end
    end
  end

  context 'with config' do
    let(:ignored_paths) { [] }
    let(:custom_matchers) { [] }
    let(:config) do
      {
        'ignored_paths' => ignored_paths,
        'custom_matchers' => custom_matchers
      }
    end
    subject { Sanctify::Scanner.new({repo: @path, config: config}).run }

    context 'with ignored paths' do
      let(:ignored_paths) { ['te.*'] }
      let(:payload) { "AKIASECRET123456789Z" }
      it 'does not raise an error' do
        expect{ subject }.not_to raise_error
      end
    end

    context 'with custom matchers' do
      let(:custom_matchers) do
        [{
            description: "Test",
            regex: "^https:\/\/"
        }]
        let(:payload) { "https://github.com/onetwopunch/sanctify" }
        it 'raises an error' do
          expect{ subject }.to raise_error(Sanctify::ScannerError)
        end
      end
    end
  end
end
