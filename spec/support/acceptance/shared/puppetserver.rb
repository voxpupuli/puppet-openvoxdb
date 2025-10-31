# frozen_string_literal: true

shared_examples 'puppetserver' do
  let(:pp) { File.read(File.join(File.dirname(__FILE__), 'puppetserver.pp')) }

  it 'applies idempotently' do
    apply_manifest(pp, expect_failures: false, debug: ENV.key?('DEBUG'))
    apply_manifest(pp, expect_failures: false, debug: ENV.key?('DEBUG'))
  end
end
