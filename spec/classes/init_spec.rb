require 'spec_helper'
describe 'nmon' do

  context 'with defaults for all parameters' do
    it { should contain_class('nmon') }
  end
end
