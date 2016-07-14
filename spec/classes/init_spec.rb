require 'spec_helper'
describe 'certbot' do

  context 'with defaults for all parameters' do
    it { should contain_class('certbot') }
  end
end
