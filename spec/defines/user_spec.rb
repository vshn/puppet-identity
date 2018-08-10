require 'spec_helper'

describe 'identity::user', :type => :define do
  let(:title) { 'testuser'}

  it { should contain_user('testuser') }
  it { should contain_class('identity') }

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    let(:facts) { { 'osfamily' => 'Debian' } }
    it { should contain_group('testuser') }
    it { should contain_user('testuser').with_ensure('absent') }
    it { should contain_group('testuser').with_ensure('absent') }
    it { should contain_exec('crontab-remove-testuser') }
    it { should contain_exec('pkill-user-testuser') }
    it { should contain_package('procps') }

    context 'on RedHat' do
      let(:facts) { { 'osfamily' => 'RedHat' } }
      it { should contain_package('procps-ng') }
    end
  end

  # ignore_uid_gid functionality
  context 'with ignore_uid_gid => false and uid define' do
    let(:params) { { 'ignore_uid_gid' => false, 'uid' => 1000 } }
    it { should contain_group('testuser') }
    it { should contain_user('testuser').with_uid(1000) }
    it { should contain_group('testuser').with_gid(1000) }
  end
  context 'with ignore_uid_gid => true and uid defined' do
    let(:params) { { 'ignore_uid_gid' => true, 'uid' => 1000 } }
    it { should contain_group('testuser') }
    it { should contain_user('testuser').with_uid(nil) }
    it { should contain_group('testuser').with_gid(nil) }
  end

  # manage_dotfiles and manage_home
  context 'with manage_dotfiles => true' do
    let(:params) { { 'manage_dotfiles' => true } }
    it { should contain_group('testuser') }
    it { should contain_file('/home/testuser').with_ensure('directory') }
    it { should contain_file('/home/testuser').with_mode('0755') }
  end
  context 'with manage_dotfiles => true and manage_home => false' do
    let(:params) { { 'manage_dotfiles' => true, 'manage_home' => false } }
    it { should contain_group('testuser') }
    it { should_not contain_file('/home/testuser') }
  end
  context 'with home_perms => 0700' do
    let(:params) { { 'home_perms' => '0700' } }
    it { should contain_group('testuser') }
    it { should contain_file('/home/testuser').with_ensure('directory') }
    it { should contain_file('/home/testuser').with_mode('0700') }
  end
  context 'with membership => minimum' do
    let(:params) { { 'membership' => 'minimum' } }
    it { should contain_user('testuser').with_membership('minimum') }
  end
  context 'with membership => miniminclusive' do
    let(:params) { { 'membership' => 'inclusive' } }
    it { should contain_user('testuser').with_membership('inclusive') }
  end

  # manage_group
  context 'with manage_group => false' do
    let(:params) { { 'manage_group' => false, 'gid' => 'test' } }
    let(:pre_condition) do
      'group { "test":
        gid => "3210",
      }'
    end
    it { should contain_group('test') }
    it { should_not contain_group('testuser') }
  end

  # ssh keys
  describe "with ssh keys" do
    let(:params) {{
      :ssh_keys => { 'main' => { 'key' => 'thisisnotakey' } }
    }}
    it { should contain_group('testuser') }
    it { is_expected.to have_ssh_authorized_key_resource_count(1) }
    it { is_expected.to contain_ssh_authorized_key('testuser-main') }
  end

end
