require 'spec_helper'

describe 'identity::user', :type => :define do
  let(:title) { 'testuser'}

  it { should contain_user('testuser') }
  it { should contain_group('testuser') }

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_user('testuser').with_ensure('absent') }
    it { should contain_group('testuser').with_ensure('absent') }
  end

  # ignore_uid_gid functionality
  context 'with ignore_uid_gid => false and uid define' do
    let(:params) { { 'ignore_uid_gid' => false, 'uid' => 1000 } }
    it { should contain_user('testuser').with_uid(1000) }
    it { should contain_group('testuser').with_gid(1000) }
  end
  context 'with ignore_uid_gid => true and uid defined' do
    let(:params) { { 'ignore_uid_gid' => true, 'uid' => 1000 } }
    it { should contain_user('testuser').with_uid(nil) }
    it { should contain_group('testuser').with_gid(nil) }
  end

end
