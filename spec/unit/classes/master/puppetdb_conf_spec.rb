require 'spec_helper'

describe 'openvoxdb::master::puppetdb_conf', type: :class do
  let :node do
    'puppetdb.example.com'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(puppetversion: Puppet.version,
                    service_provider: 'systemd',
                    selinux: false)
      end

      let(:pre_condition) { 'class { "openvoxdb": }' }

      it {
        is_expected.to contain_ini_setting('soft_write_failure')
          .with_setting('soft_write_failure')
          .with_value(false)
      }

      context 'when using default values' do
        it { is_expected.to contain_ini_setting('puppetdbserver_urls').with(value: 'https://localhost:8081/') }
      end

      context 'when using several servers' do
        let(:params) { { server: ['puppetdb1.example.com', 'puppetdb2.example.com'] } }

        it { is_expected.to contain_ini_setting('puppetdbserver_urls').with(value: 'https://puppetdb1.example.com:8081/,https://puppetdb2.example.com:8081/') }
      end

      context 'when using legacy_terminus' do
        let(:params) { { legacy_terminus: true } }

        it { is_expected.to contain_ini_setting('puppetdbserver').with(value: 'localhost') }
        it { is_expected.to contain_ini_setting('puppetdbport').with(value: '8081') }

        context 'with several servers' do
          let(:params) { super().merge(server: ['puppetdb1.example.com', 'puppetdb2.example.com']) }

          it { is_expected.to compile.and_raise_error(%r{only supports a single PuppetDB server}) }
        end
      end
    end
  end
end
