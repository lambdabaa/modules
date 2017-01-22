require_relative '../lib/interop'

RSpec.describe Interop do
  before(:each) do
    @base64 = Interop.import('base64')['Base64']
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
