Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      match   '/anagrams/:word', :to => 'words#show', :via => [:get], :as => :showAnagram
      match '/stats', :to => 'words#stats', :via => [:get], :as => :stats
      match '/words', :to => 'words#create', :via => [:post], :as => :createDictionary
      match '/words', :to => 'words#clear', :via => [:delete], :as => :clearDictionary
      match '/words/:word', :to => 'words#destroy', :via => [:delete], :as => :deleteWord
      match '/words/test', :to => 'words#test_anagrams', :via => [:get], :as => :testAnagrams
      match '/word_groups/:word', :to => 'words#destroy_group', :via => [:delete], :as => :deleteWordGroup
      match '/word_groups/by_size/:size', :to => 'words#show_by_group_size', :via => [:get], :as => :getGroups
      match '/word_groups/largest', :to => 'words#largest_group', :via => [:get], :as => :largestWordGroup
    end
  end
end
