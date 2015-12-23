require 'rails_helper'

RSpec.describe ReadmeInterpreter do

  it "should parse the README into HTML" do
    interpret_result = ReadmeInterpreter.new("README.md").create_api_page
    line_from_readme = '<p>Create a user with the username <code class="prettyprint">testuser</code>.</p>'
    
    expect(interpret_result).to include line_from_readme
  end

end
