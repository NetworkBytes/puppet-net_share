require 'tempfile'

Given /^the manifest$/ do |text|
  @manifest = text
end

When /^puppet applies the manifest$/ do
  manifest_file = Tempfile.new('manifest')

  begin
    manifest_file.write @manifest
    manifest_file.close

    # Have to call puppet via cmd to prevent this ruby process's environment variables being passed to puppet
    system("cmd", "/c", File.join(ENV['ProgramFiles(x86)'], 'Puppet Labs/Puppet/bin/puppet.bat'), 'apply', '--debug', '--detailed-exitcodes', '--modulepath', './modules', manifest_file.path)

    @changes = false
    @failures = false

    # See http://docs.puppetlabs.com/man/agent.html for a dexcription of puppet agent's exit codes
    # when using the --detailed-exitcodes option
    @changes = ($?.exitstatus & 2) > 0
    @failures = ($?.exitstatus & 4) > 0

    raise "puppet apply failed.  Exit code #{$?.exitstatus}" if $?.exitstatus < 0 or $?.exitstatus > 6
    raise "puppet apply generated failures.  Exit code #{$?.exitstatus}" if @failures
  ensure
    manifest_file.delete
  end
end

Then /^puppet has made changes$/ do
  @changes.should == true
end

Then /^puppet has not made changes$/ do
  @changes.should == false
end