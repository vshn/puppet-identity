require 'spec_helper'

describe 'identity' do
  describe "class without any parameters" do
    let(:params) {{ }}
    it { is_expected.to compile.with_all_deps }
  end
  describe "class with manage_skel true" do
    let(:params) {{
      :manage_skel => true
    }}
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/skel') }
  end
  describe "class with user defined" do
    let(:params) {{
      :users => { 'testuser' => { 'uid' => '1000' } }
    }}
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_user_resource_count(1) }
    it { is_expected.to contain_identity__user('testuser') }
  end
  describe "class with group defined" do
    let(:params) {{
      :groups => { 'testuser' => { 'gid' => '1000' } }
    }}
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_group_resource_count(1) }
    it { is_expected.to contain_identity__group('testuser') }
  end
end
