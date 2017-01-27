require_relative '../lib/modules'

RSpec.describe Loader do
  before(:each) do
    @basepath = File.dirname(__FILE__) + '/fixtures'
    modules.config(basepath: @basepath)
  end

  it "#config" do
    expect(Loader.instance_variable_get :@basepath).to eq @basepath
  end

  it "#import" do
    reverse = import('./reverse')
    expect(reverse.call('123')).to eq '321'
  end

  it "missing file error" do
    expect { import('./syntax_error') }.to raise_error(LoadError)
  end
end
