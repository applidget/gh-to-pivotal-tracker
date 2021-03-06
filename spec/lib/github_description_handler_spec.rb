require 'spec_helper'
require "byebug"

describe GithubDescriptionHandler do
  
  it "replaces a text when it exists" do
    text = %{
      Do someting
      
      Do not forget to do smething else. 
      Process the following TODO list:
      - [ ] TODO1
      - [ ] TODO2
      - [ ] TODO3
      
      ---
}
    
    result = GithubDescriptionHandler.replace_or_append(text, "something", /---/)
    expected = %{
      Do someting
      
      Do not forget to do smething else. 
      Process the following TODO list:
      - [ ] TODO1
      - [ ] TODO2
      - [ ] TODO3
      
      something
}
    
    expect(result).to eq(expected)
  end
  
  it "appends a text when it does not exist" do
    text = %{
              Do someting

              Do not forget to do smething else. 
              Process the following TODO list:
              - [ ] TODO1
              - [ ] TODO2
              - [ ] TODO3}
    
    result = GithubDescriptionHandler.replace_or_append(text, "something", /---/)
    expected = %{
              Do someting

              Do not forget to do smething else. 
              Process the following TODO list:
              - [ ] TODO1
              - [ ] TODO2
              - [ ] TODO3
something}
    
    expect(result).to eq(expected)
  end
  
  it "computes eta string based on params" do
    eta1 = Date.parse('2015-11-03') 
    eta2 = Date.parse('2015-11-06')
    res = GithubDescriptionHandler.eta_string(current: eta1, previous: eta2)
    expect(res).to eq("*ETA*: **3rd November 2015**")
    
    res = GithubDescriptionHandler.eta_string(current: eta1, previous: eta2, display_previous: true)
    expect(res).to eq("*ETA*: **3rd November 2015** (was 6th November 2015)")
  end
  
  it "correctly formats an ETA comment" do
    eta1 = Date.parse('2015-11-03') 
    eta2 = Date.parse('2015-11-06')
    url = "http://google.com"
    res = GithubDescriptionHandler.eta_comment(current: eta1, previous: eta2, display_previous: true, url: url)
    expected = ":checkered_flag: *New* *ETA*: **3rd November 2015** (was 6th November 2015)\nView in [Pivotal Tracker](http://google.com)"
    expect(res).to eq(expected)
  end
  
  it "updates a github description correctly, even when called a second time" do 
    eta1 = Date.parse('2015-11-03') 
    eta2 = Date.parse('2015-11-06')
    body = %{Hello}
    options = {
      id: "87656789", 
      url: "http://apple.com",
      body: body
    }
    
    res = GithubDescriptionHandler.process_description options
    expected = %{Hello

--- 
**Pivotal Tracker** - [#87656789](http://apple.com)


--- 
}
    expect(res).to eq(expected)
    
    options = {
      id: "87656789", 
      url: "http://apple.com",
      body: res
    }
    res2 = GithubDescriptionHandler.process_description options
    expect(res2).to eq(expected)
    
  end
  
end