Facter.add(:openvoxdb_version) do
  confine { Facter::Core::Execution.which('puppetdb') }

  setcode do
    output = Facter::Core::Execution.execute('puppetdb --version')
    output.split(':').last.strip
  rescue Facter::Core::Execution::ExecutionFailure
    nil
  end
end
