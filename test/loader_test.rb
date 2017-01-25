require_relative '../lib/global'
require_relative '../lib/loader'

RSpec.describe Loader do
  before(:each) do
    Loader.set_basepath(File.dirname(__FILE__) + '/fixtures')
  end

  it "#import" do
    reverse = Loader.import('./reverse')
    expect(reverse.call('123')).to eq '321'
  end
end
