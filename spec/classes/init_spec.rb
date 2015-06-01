require 'spec_helper'

describe 'identity' do
  describe "class without managing users and groups" do
    let(:params) {{
      :manage_users => false,
      :manage_groups => false,
    }}
    it { is_expected.to compile.with_all_deps }
  end
  describe "class with manage_skel true" do
    let(:params) {{
      :manage_skel => true,
      :manage_groups => false,
      :manage_users => false,
    }}
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/skel') }
  end
  describe "class with user defined" do
    let(:params) {{
      :manage_groups => false,
      :users => { 'testuser' => { 'uid' => '1000' } }
    }}
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_user_resource_count(1) }
    it { is_expected.to contain_identity__user('testuser') }
  end
  describe "class with hiera user defined" do
    let(:params) {{
      :manage_groups => false,
    }}
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_user_resource_count(2) }
    it { is_expected.to contain_identity__user('testuser1') }
    it { is_expected.to contain_identity__user('testuser2') }
  end
  describe "class with group defined" do
    let(:params) {{
      :manage_users => false,
      :groups => { 'testuser' => { 'gid' => '1000' } }
    }}
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_group_resource_count(1) }
    it { is_expected.to contain_identity__group('testuser') }
  end
  describe "class with hiera group defined" do
    let(:params) {{
      :manage_users => false,
    }}
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_group_resource_count(2) }
    it { is_expected.to contain_identity__group('testgroup1') }
    it { is_expected.to contain_identity__group('testgroup2') }
  end
  describe "class with hiera users and group defined and managed" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_group_resource_count(4) }
    it { is_expected.to have_user_resource_count(2) }
    it { is_expected.to contain_identity__user('testuser1') }
    it { is_expected.to contain_identity__user('testuser2') }
    it { is_expected.to contain_user('testuser1') }
    it { is_expected.to contain_user('testuser2') }
    it { is_expected.to contain_group('testuser1') }
    it { is_expected.to contain_group('testuser2') }
    it { is_expected.to contain_file('/home/testuser1') }
    it { is_expected.to contain_file('/home/testuser2') }
    it { is_expected.to contain_identity__group('testgroup1') }
    it { is_expected.to contain_identity__group('testgroup2') }
    it { is_expected.to contain_group('testgroup1') }
    it { is_expected.to contain_group('testgroup2') }
  end
end
