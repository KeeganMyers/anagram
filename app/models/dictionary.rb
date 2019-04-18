##
#This class is a singelton used to store the current state of the dictonary in
#memory. To expedite access to word groups the dictionary is structured as a
#hashMap of sets. Since the word's prime value is invariant to letter order the
#prime value is used as the hashMap key. This allows fast access to all
#anagrams of a word. Sets were used as the values as by nature they are more
#efficient to iterate, randomly access, and automatically prevent duplication
#of words.
##
class Dictionary

class << self
public
@@words = Hash.new { |hash, key| hash[key] = Set.new() }

  ##
  #adds a word to the dictionary singelton
  ##
 def append(word)
   self.clear_memoized
   @@words[word.to_prime] << word
 end
 
 ##
 #remove all words from the dictionary
 ##
 def clear
   self.clear_memoized
   @@words.clear
 end

  ##
  # Given an instance of word find all anagrams of that word and return the
  # results as an array of String.
  # Optional parameters are present to allow limiting the number of anagrams
  # returned, or filter proper nouns out of the returned array
  ##
  def find(word, limit = nil, proper_nouns = true)
    word_set = @@words[word.to_prime]
    if !word_set.empty?
     if !proper_nouns
       word_set = word_set.select {|dict_word| !dict_word.is_proper_noun?}
                          .map(&:raw_value).to_set
     else
        word_set = word_set.map(&:raw_value).to_set
     end
      if limit.nil?
        word_set.delete word.raw_value
      else
        word_set.delete(word.raw_value).first(limit)
      end
   else
     word_set
    end
  end

  ##
  #Remove a single word from the dictionary based on its raw value
  ##
  def remove_word(word)
    if @@words[word.to_prime].present? && !@@words[word.to_prime].select {|dict_word| dict_word.raw_value == word.raw_value}
                                                                .empty?
      self.clear_memoized
      @@words[word.to_prime].select! {|dict_word| dict_word.raw_value != word.raw_value}
      true
    else
      false
    end
  end

  ##
  # Remove all anagrams of a single word from the dictionary
  ##
  def remove_group(word)
      self.clear_memoized
      @@words.delete(word.to_prime).present?
  end

  ##
  # Return all anagram groups of a specified size as a array of array of string
  # #
  def groups_with_size(x)
    if x.is_a? Integer
      @@words
          .select {|word_prime, words| words.count == x}
          .values
          .inject([]) {|result, group| result << group.map(&:raw_value)}
    end
  end

  ##
  # Returns the largest group of anagrams in the dictionary
  ##
  def largest_group
    self.sort_by_group_size
        .last
        .last
        .map(&:raw_value)
  end

  ##
  # Returns the smallest group of anagrams in the dictionary
  ##
  def smallest_group
    self.sort_by_group_size
        .first
        .last
        .map(&:raw_value)
  end

  ##
  #Returns the shortest word length in the dictionary
  ##
  def shortest_word
    word = self.sort_by_word_length
        .first
    word.present? ? word.length : 0
  end

  ##
  #Returns the longest word length in the dictionary
  ##
  def longest_word
    word = self.sort_by_word_length
        .last
    word.present? ? word.length : 0
  end

  ##
  # Return a count of all words in the dictionary
  ##
  def word_count
    self.flatten.count
  end

  def median_word
    middle_index = @@words.count >= 0 ? @@words.count / 2 : 0
    word = self.sort_by_word_length[middle_index]
    word.present? ? word.length : 0
  end

  def average_word_length
    words = self.flatten
    count = words.count > 0 ? words.count  : 1
    words.inject(0) {|total_length, word| total_length + word.length} / count
  end

  def are_anagrams?(words)
    words.each.inject(Set.new()) {|word_set,word| word_set << Word.new(word).to_prime}
              .count == 1
  end

  protected
  ##
  # Since calculated values are memoized the values must be cleared so that the
  # calculated values are always acurate. This function should be called each
  # time the dictionary is mutated to ensure accuracy
  ##
  def clear_memoized
    @flat_set = nil
    @sorted_words = nil
    @sorted_groups = nil
  end

  ##
  # Flatten the hashMap of sets into a single large set
  ###
  def flatten
    @flat_set || @@words
        .values
      .inject(Set.new()) {|result, word_set| result.merge(word_set.map(&:value))}
  end

  ##
  #Sorts the flattened dictionary so that the metrics can be easily reported
  ##
  def sort_by_word_length
    @sorted_words || self.flatten
                    .sort_by {|word| word.length}
  end

  ##
  #Sorts the dictionary by the size of word groups
  ##
  def sort_by_group_size
     @sorted_groups || @@words.sort_by {|word_prime, words| words.count}
  end
 end
end
