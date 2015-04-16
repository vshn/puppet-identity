require 'spec_helper'

describe 'identity::group', :type => :define do
  let(:title) { 'testuser'}

  it { should contain_group('testuser') }

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_group('testuser').with_ensure('absent') }
  end
  context 'with gid => 1000' do
    let(:params) { { 'gid' => 1000 } }
    it { should contain_group('testuser').with_gid(1000) }
  end

end
