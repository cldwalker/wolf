When /^I expect open with "([^"]*)"$/ do |url|
  Wolf::Mouth.should_receive(:open).with(url)
end

Given /^an xml file "([^"]*)"$/ do |file|
  When %[a file named "#{file}" with:],
    File.read(File.dirname(__FILE__)+'/../support/'+file)
end

When /^I expect query "([^"]*)"$/ do |query|
  Wolfram.should_receive(:query).and_return
    Wolfram::Query.new query
end

Then /^the output contains the current version$/ do
  Then %{the output should match /^#{Wolf::VERSION}/}
end
