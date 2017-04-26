require 'spec_helper'
describe 'existdb' do
  context 'with default values for all parameters' do
    it { should contain_class('existdb') }
  end
end
