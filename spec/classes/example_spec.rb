require 'spec_helper'

describe 'identity' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "identity class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('identity::params') }
        it { is_expected.to contain_class('identity::install').that_comes_before('identity::config') }
        it { is_expected.to contain_class('identity::config') }
        it { is_expected.to contain_class('identity::service').that_subscribes_to('identity::config') }

        it { is_expected.to contain_service('identity') }
        it { is_expected.to contain_package('identity').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'identity class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('identity') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
