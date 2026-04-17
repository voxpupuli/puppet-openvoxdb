require 'spec_helper'

describe 'openvoxdb::master::config', type: :class do
  let(:node) { 'puppetdb.example.com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:termini_package_name) do
        case facts[:os]['family']
        when 'Archlinux', 'OpenBSD'
          'puppetdb-termini'
        when 'Debian', 'RedHat', 'Suse', 'Gentoo'
          'openvoxdb-termini'
        end
      end

      context 'when PuppetDB on remote server' do
        context 'when using default values' do
          it { is_expected.to compile.with_all_deps }
        end
      end

      context 'when PuppetDB and Puppet Master are on the same server' do
        context 'when using default values' do
          let(:pre_condition) { 'class { "openvoxdb": }' }

          it {
            is_expected.to contain_puppetdb_conn_validator('puppetdb_conn').with(
              puppetdb_server: 'puppetdb.example.com',
              puppetdb_port: '8081',
              use_ssl: 'true',
            )
          }
        end

        context 'when puppetdb class is declared with disable_ssl => true' do
          let(:pre_condition) { 'class { "openvoxdb": disable_ssl => true }' }

          it {
            is_expected.to contain_puppetdb_conn_validator('puppetdb_conn').with(
              puppetdb_port: '8080',
              use_ssl: 'false',
            )
          }
        end

        context 'when puppetdb_port => 1234' do
          let(:pre_condition) { 'class { "openvoxdb": }' }
          let(:params) { { puppetdb_port: '1234' } }

          it {
            is_expected.to contain_puppetdb_conn_validator('puppetdb_conn').with(
              puppetdb_port: '1234',
              use_ssl: 'true',
            )
          }
        end

        context 'when puppetdb_port => 1234 AND the puppetdb class is declared with disable_ssl => true' do
          let(:pre_condition) { 'class { "openvoxdb": disable_ssl => true }' }
          let(:params) { { puppetdb_port: '1234' } }

          it {
            is_expected.to contain_puppetdb_conn_validator('puppetdb_conn').with(
              puppetdb_port: '1234',
              use_ssl: 'false',
            )
          }
        end

        context 'when using default values' do
          it { is_expected.to contain_package(termini_package_name).with(ensure: 'present') }
          it { is_expected.to contain_puppetdb_conn_validator('puppetdb_conn').with(test_url: '/pdb/meta/v1/version') }
        end
      end

      context 'when restart_puppet is true' do
        let(:pre_condition) { 'class { "openvoxdb": }' }

        context 'with create_puppet_service_resource as default' do
          let(:params) do
            {
              puppet_service_name: 'puppetserver',
              restart_puppet: true,
            }
          end

          it { is_expected.to contain_service('puppetserver').with(ensure: 'running') }
        end

        context 'with create_puppet_service_resource = true' do
          let(:params) do
            {
              create_puppet_service_resource: true,
              puppet_service_name: 'puppetserver',
              restart_puppet: true,
            }
          end

          it { is_expected.to contain_service('puppetserver').with(ensure: 'running') }
        end

        context 'with create_puppet_service_resource = false' do
          # Also setting the various parameters that notify the service to be false. Otherwise this error surfaces:
          # `Could not find resource 'Service[puppetserver]' for relationship from 'Class[Openvoxdb::Master::Puppetdb_conf]'`
          let(:params) do
            {
              create_puppet_service_resource: false,
              manage_config: false,
              manage_report_processor: false,
              manage_routes: false,
              puppet_service_name: 'puppetserver',
              restart_puppet: true,
            }
          end

          it { is_expected.not_to contain_service('puppetserver') }
        end
      end
    end
  end
end
