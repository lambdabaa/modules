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

  it "missing file error" do
    expect { Loader.import('./syntax_error') }.to raise_error(LoadError)
  end
end
