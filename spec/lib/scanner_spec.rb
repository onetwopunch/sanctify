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

    context 'with AWS Secret Key' do
      let(:payload) { "pIW/g216XEHyoF+dIHkYgh439nGko8ga65VTusGF" }
      it 'raises an error' do
        expect{ subject }.to raise_error(Sanctify::ScannerError)
      end
    end

    context 'with AWS Secret Key that does not have a "/" character' do
      let(:payload) { "pIW+g216XEHyoF+dIHkYgh439nGko8ga65VTusGF" }
      it 'raises an error' do
        expect{ subject }.to raise_error(Sanctify::ScannerError)
      end
    end

    context 'with an innocent 40-character path using a base64 alphabet' do
      let(:payload) { "yourlibrary/some/40/character/path/Thing" }
      it 'does not raise an error' do
        expect{ subject }.not_to raise_error
      end
    end

    context 'with a 40-character string using a base64 alphabet' do
      let(:payload) { "OKIKnowSomeClassNamesAreJustReallyLongOK" }
      it 'does not raise an error' do
        expect{ subject }.not_to raise_error
      end
    end

    context 'with git sha' do
      let(:payload) { "a74e98e6c224a9d2dba20c858009a4cb51689822" }
      it 'does not raise an error' do
        expect{ subject }.not_to raise_error
      end
    end

    context 'with long paths' do
      let(:payload) { "yyyyyy/tttt/ggggggggg/aaa_aaaa_aaaaaaaa/_bbbb_/cccc_dd_eeeee_vvvvvvv/bbbbb_iiiiiiii.yml" }
      it 'does not raise an error' do
        expect{ subject }.not_to raise_error
      end
    end

    context 'with AWS Secret Key' do
      let(:payload) { "pIW/g216XEHyoF+dIHkYgh439nGko8ga65VTusGF" }
      it 'raises an error' do
        expect{ subject }.to raise_error(Sanctify::ScannerError)
      end
    end
  end

  context 'with config' do
    let(:ignored_paths) { [] }
    let(:custom_matchers) { [] }
    let(:disabled_matchers){ [] }
    let(:config) do
      {
        'ignored_paths' => ignored_paths,
        'custom_matchers' => custom_matchers,
        'disabled_matchers' => disabled_matchers
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

    context 'with disabled_matchers' do
      let(:disabled_matchers) { ['aws_secret_key'] }
      let(:payload) { "pIW/g216XEHyoF+dIHkYgh439nGko8ga65VTusGF" }
      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
