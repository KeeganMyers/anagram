require 'swagger_helper'
require 'spec_helper'


describe "Anagrams", :type => :request do
  #include Warden::Test::Helpers
  before(:each) do
    post "/api/v1/words.json", :params => {:words => ["read", "dear", "dare"]}
  end

  after(:each) do
    delete '/api/v1/words.json'
  end

  it "should allow users to upload new words to the dictionary" do
    post "/api/v1/words.json", :params => {:words => ["read", "dear", "dare"]}
    expect(response.status).to eq(201)
  end

  it "should allow users to fetch anagrams from the dictionary" do

    get "/api/v1/anagrams/read.json"
    expect(response.status).to eq(200)

    body = JSON.parse(response.body)
    expect(body["anagrams"].sort).to eq(["dare","dear"])
  end

  it "should allow users to filter proper nouns out of the results" do

    post "/api/v1/words.json", :params => {"words" => ["Ubuntu", "buntuu", "untuub"]}
    expect(response.status).to eq(201)

    get "/api/v1/anagrams/buntuu.json", :params => {"proper_nouns": 0}
    expect(response.status).to eq(200)


    body = JSON.parse(response.body)
    expect(body["anagrams"].sort).to eq(["untuub"])
  end

  it "should allow users to limit the number of results returned" do
    get "/api/v1/anagrams/read.json", :params => {:limit => 1}
    expect(response.status).to eq(200)

    body = JSON.parse(response.body)
    expect(body['anagrams'].size).to eq(1)
  end

  it "should return an empty vector if no anagrams are found" do

    get "/api/v1/anagrams/zyxwv.json"
    expect(response.status).to eq(200)

    body = JSON.parse(response.body)
    expect(body['anagrams'].size).to eq(0)
  end

  it "should allow users to delete all words in the dictionary" do
    delete "/api/v1/words.json"
    expect(response.status).to eq(204)

    get "/api/v1/anagrams/read.json"
    expect(response.status).to eq(200)

    body = JSON.parse(response.body)
    expect(body['anagrams'].size).to eq(0)
  end

  it "should allow the dictionary to be cleared multiple times without issue" do

    3.times do
      delete "/api/v1/words.json"
      expect(response.status).to eq(204)
    end

    get "/api/v1/anagrams/read.json"
    expect(response.status).to eq(200)

    body = JSON.parse(response.body)
    expect(body['anagrams'].size).to eq(0)
  end

  it "should allow removal of a single word from the dictionary" do
    delete "/api/v1/words/dear.json"
    expect(response.status).to eq(204)

    get "/api/v1/anagrams/read.json"
    expect(response.status).to eq(200)
    body = JSON.parse(response.body)
    expect(body["anagrams"].sort).to eq(["dare"])
  end

  it "should allow removal of a word and all its anagrams" do

    post "/api/v1/words.json", :params => {"words" => ["Ubuntu", "buntuu", "untuub"]}
    expect(response.status).to eq(201)

    delete "/api/v1/word_groups/Ubuntu.json"
    expect(response.status).to eq(204)

    #should have  removed entire group
    get "/api/v1/anagrams/Ubuntu.json"
    expect(response.status).to eq(200)
    body = JSON.parse(response.body)

    assert_equal([], body["anagrams"])

    #should not have removed other groups
    get "/api/v1/anagrams/read.json"
    expect(response.status).to eq(200)
    body = JSON.parse(response.body)
    expect(body["anagrams"].sort).to eq(['dare', 'dear'])
  end

  it "should show the largest group on anagrams" do

    post "/api/v1/words.json", :params => {"words" => ["Ubuntu", "buntuu", "untuub"]}
    expect(response.status).to eq(201)

    get "/api/v1/word_groups/largest.json"
    body = JSON.parse(response.body)
    expect(body["anagrams"].sort).to eq(["Ubuntu", "buntuu", "untuub"])
  end

  it "should show anagrams groups of a specific size" do
    post "/api/v1/words.json", :params => {"words" => ["Ubuntu", "buntuu", "untuub", "ntuubu"]}
    expect(response.status).to eq(201)

    get "/api/v1/word_groups/by_size/4.json"
    body = JSON.parse(response.body)
    expect(body["anagram_groups"].sort).to eq([["Ubuntu", "buntuu", "untuub", "ntuubu"]])
  end

  it "should return an empty vector if an anagram group size is not present" do
    get "/api/v1/word_groups/by_size/12.json"
    body = JSON.parse(response.body)
    expect(body["anagram_groups"]).to eq([])
  end

  it "should return a boolean indicating if a set of words are all anagrams" do
    get "/api/v1/words/test.json",:params => {"words" => ["read", "dear", "dare"]}
    expect(response.status).to eq(200)
    body = JSON.parse(response.body)
    expect(body["anagrams"]).to eq(true)
  end


  it "should return a boolean indicating if a set of words are all anagrams" do
    get "/api/v1/words/test.json",:params => {"words" => ["read", "dear", "dare" "test"]}
    expect(response.status).to eq(200)
    body = JSON.parse(response.body)
    expect(body["anagrams"]).to eq(false)
  end

  it "should show a list of stats about the current dictionary" do
     post "/api/v1/words.json", :params =>  {"words" => ["Ubuntu", "buntuu", "untuub", "ntuubu"]}
    get "/api/v1/stats.json"
    expect(response.status).to eq(200)
    body = JSON.parse(response.body)
    expect(body["count"]).to eq(7)
    expect(body["min"]).to eq(4)
    expect(body["max"]).to eq(6)
    expect(body["average"]).to eq(5)
  end

end
