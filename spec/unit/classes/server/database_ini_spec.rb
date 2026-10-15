require 'spec_helper'

describe 'openvoxdb::server::database', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }

  it { is_expected.to contain_class('openvoxdb::server::database') }

  describe 'when using (literal) facts_blocklist' do
    let(:params) do
      {
        'facts_blocklist' => %w[
          one_fact
          another_fact
        ],
      }
    end

    it {
      is_expected.to contain_ini_setting('puppetdb_facts_blocklist')
        .with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
          'section' => 'database',
          'setting' => 'facts-blocklist',
          'value'   => 'one_fact, another_fact',
        )
    }
  end

  describe 'when using facts_blocklist_type' do
    let(:params) do
      {
        'facts_blocklist_type' => 'regex',
      }
    end

    it {
      is_expected.to contain_ini_setting('puppetdb_facts_blocklist_type')
        .with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
          'section' => 'database',
          'setting' => 'facts-blocklist-type',
          'value'   => 'regex',
        )
    }
  end

  describe 'deprecated facts-blacklist is ensured absent' do
    it {
      is_expected.to contain_ini_setting('puppetdb_facts_blacklist (deprecated)')
        .with(
          'ensure'  => 'absent',
          'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
          'section' => 'database',
          'setting' => 'facts-blacklist',
        )
    }
  end

  describe 'without any facts_blocklist settings' do
    it {
      is_expected.to contain_ini_setting('puppetdb_facts_blocklist')
        .with(
          'ensure'  => 'absent',
          'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
          'section' => 'database',
          'setting' => 'facts-blocklist',
          'value'   => '',
        )
      is_expected.to contain_ini_setting('puppetdb_facts_blocklist_type')
        .with(
          'ensure'  => 'absent',
          'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
          'section' => 'database',
          'setting' => 'facts-blocklist-type',
        )
        .without('value')
    }
  end

  describe 'when setting max pool size' do
    context 'on current PuppetDB' do
      describe 'to a numeric value' do
        let(:params) do
          {
            'database_max_pool_size' => 12_345,
          }
        end

        it {
          is_expected.to contain_ini_setting('puppetdb_database_max_pool_size')
            .with(
              'ensure'  => 'present',
              'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
              'section' => 'database',
              'setting' => 'maximum-pool-size',
              'value'   => '12345',
            )
        }
      end

      describe 'to absent' do
        let(:params) do
          {
            'database_max_pool_size' => 'absent',
          }
        end

        it {
          is_expected.to contain_ini_setting('puppetdb_database_max_pool_size')
            .with(
              'ensure'  => 'absent',
              'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
              'section' => 'database',
              'setting' => 'maximum-pool-size',
            )
        }
      end
    end
  end

  describe 'when using ssl communication' do
    let(:params) do
      {
        'postgresql_ssl_on' => true,
        'ssl_key_pk8_path' => '/tmp/private_key.pk8',
      }
    end

    it 'configures subname correctly' do
      is_expected.to contain_ini_setting('puppetdb_subname')
        .with(
          ensure: 'present',
          path: '/etc/puppetlabs/puppetdb/conf.d/database.ini',
          section: 'database',
          setting: 'subname',
          value: '//localhost:5432/puppetdb?' \
                 'ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&' \
                 'sslmode=verify-full&' \
                 'sslrootcert=/etc/puppetlabs/puppetdb/ssl/ca.pem&' \
                 'sslkey=/tmp/private_key.pk8&' \
                 'sslcert=/etc/puppetlabs/puppetdb/ssl/public.pem',
        )
    end
  end
end
