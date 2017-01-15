require_relative '../lib/requirerb'

RSpec.describe RequireRb do
  it "#internal_import" do
    dirname = File.dirname(__FILE__) + '/fixtures'
    reverse = RequireRb.internal_import(dirname, 'reverse')
    expect(reverse('123')).to eq '321'
  end

  context "#external_import" do
    before(:example) do
      @base64 = RequireRb.external_import('base64')['Base64']
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
