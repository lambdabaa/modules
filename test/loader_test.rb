require_relative '../lib/global'
require_relative '../lib/loader'

RSpec.describe Loader do
  before(:each) do
    Loader.set_basepath(File.dirname(__FILE__) + '/fixtures')
  end

  it "#internal_import" do
    reverse = Loader.internal_import('reverse')
    expect(reverse('123')).to eq '321'
  end

  context "#external_import" do
    before(:example) do
      @base64 = Loader.external_import('base64')['Base64']
    end

    it "core lib" do
      input = 'hello ruby'
      # TODO(ari): Why are these private?
      expect(@base64.send(:strict_decode64, @base64.send(:strict_encode64, input))).to eq input
    end

    it "does not pollute global namespace" do
      expect(defined? Base64).to eq nil
    end
  end
end
