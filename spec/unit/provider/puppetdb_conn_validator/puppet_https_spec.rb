# frozen_string_literal: true

require 'spec_helper'
require 'puppet/util/puppetdb_validator'

describe Puppet::Type.type(:puppetdb_conn_validator).provider(:puppet_https) do
  let(:resource) do
    Puppet::Type.type(:puppetdb_conn_validator).new(
      name: 'puppetdb_conn',
      puppetdb_server: puppetdb_server,
      puppetdb_port: 8081,
      timeout: 0,
      provider: :puppet_https,
    )
  end
  let(:provider) { resource.provider }
  let(:up) { instance_double(Puppet::Util::PuppetdbValidator, attempt_connection: true, puppetdb_server: 'up.example.com', puppetdb_port: 8081) }
  let(:down) { instance_double(Puppet::Util::PuppetdbValidator, attempt_connection: false, puppetdb_server: 'down.example.com', puppetdb_port: 8081) }
  let(:down2) { instance_double(Puppet::Util::PuppetdbValidator, attempt_connection: false, puppetdb_server: 'down2.example.com', puppetdb_port: 8081) }

  before do
    allow(Puppet::Util::PuppetdbValidator).to receive(:new).with('up.example.com', 8081, true, nil).and_return(up)
    allow(Puppet::Util::PuppetdbValidator).to receive(:new).with('down.example.com', 8081, true, nil).and_return(down)
    allow(Puppet::Util::PuppetdbValidator).to receive(:new).with('down2.example.com', 8081, true, nil).and_return(down2)
  end

  context 'with a single server' do
    let(:puppetdb_server) { 'up.example.com' }

    it { expect(provider.exists?).to be true }
  end

  context 'with a single unreachable server' do
    let(:puppetdb_server) { 'down.example.com' }

    it { expect(provider.exists?).to be false }
    it { expect { provider.create }.to raise_error(Puppet::Error, 'Unable to connect to puppetdb server! (down.example.com:8081)') }
  end

  context 'with several servers, the first one unreachable' do
    let(:puppetdb_server) { ['down.example.com', 'up.example.com'] }

    it { expect(provider.exists?).to be true }
  end

  context 'with several servers, the first one reachable' do
    let(:puppetdb_server) { ['up.example.com', 'down.example.com'] }

    it 'does not try the others' do
      expect(down).not_to receive(:attempt_connection)
      expect(provider.exists?).to be true
    end
  end

  context 'with several unreachable servers' do
    let(:puppetdb_server) { ['down.example.com', 'down2.example.com'] }

    it 'tries all of them' do
      expect(down).to receive(:attempt_connection)
      expect(down2).to receive(:attempt_connection)
      expect(provider.exists?).to be false
    end

    it { expect { provider.create }.to raise_error(Puppet::Error, 'Unable to connect to puppetdb server! (down.example.com:8081, down2.example.com:8081)') }
  end
end
