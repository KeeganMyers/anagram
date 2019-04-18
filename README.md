A very simple rails 5 JSON api to calculate and display anagrams. The api
provides routes to add words to a dictionary. Given the limited scope of the
demo the dictionary is expressed as a Singleton rather than using a dedicated
data store. This implementation is fairly permanent but would not scale. To
scale the project the Singleton should be replaced with a combination of Elasticsearch
(since there are NLP aspects to this project) and Redis.

##Installation

```{bash}
rvm install 2.5
rvm use 2.5
rvm gemset create anagram
rvm gemset use anagram
bundle install
```

#Testing
The tests provided have been converted into request tests


```{bash}
bundle exec rspec
```

#Usage
The api can be accessed over http. The api only accepts and returns JSON.


```{bash}
# Adding words to the corpus
$ curl -i -X POST -d '{ "words": ["read", "dear", "dare"] }' http://localhost:3000/api/v1/words.json


# Fetching anagrams
$ curl -i http://localhost:3000/api/v1/anagrams/read.json

# Specifying maximum number of anagrams
$ curl -i http://localhost:3000/api/v1/anagrams/read.json?limit=1


# Filter proper nouns out of the returned words, by default proper nouns will
# included ih the returned words
$ curl -i http://localhost:3000/api/v1/anagrams/read.json?proper_nouns=0

# Delete single word
$ curl -i -X DELETE http://localhost:3000/api/v1/words/read.json


# Delete word and all of its anagrams
$ curl -i -X DELETE http://localhost:3000/api/v1/word_groups/read.json

# Delete all words
$ curl -i -X DELETE http://localhost:3000/api/v1/words.json

#Show the largest word group in the dictionary
$ curl -i http://localhost:3000/api/v1/word_groups/largest.json

#Show word groups of a specific size
$ curl -i http://localhost:3000/api/v1/word_groups/by_size/4.json

#Show a set of stats about the current dictionary
$ curl -i http://localhost:3000/api/v1/stats.json

#Test if a collection of words are all anagrams of eachother
$ curl -i -d '{ "words": ["read", "dear", "dare"] }' http://localhost:3000/api/v1/words/test.json
```
