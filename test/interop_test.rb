require_relative '../lib/modules/interop'

RSpec.describe Interop do
  before(:each) do
    @base64 = Interop.import('base64')['Base64']
  end

  it "core lib" do
    input = 'hello ruby'
    expect(@base64.strict_decode64(@base64.strict_encode64(input))).to eq input
  end

  it "does not pollute global namespace" do
    expect(defined? Base64).to eq nil
  end

  it "save the environment" do
    subject = '{"x": 5}'
    json = Interop.import('json', save_the_environment: true)['JSON']
    expect(JSON.parse(subject)).to eq json.parse(subject)
  end
end
