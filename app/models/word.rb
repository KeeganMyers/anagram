##
#Class represents a single word in the dictionary. Values are normalized with
#naive ascii folding and downcasing, but meaningful information could also be
#lost in this process. As such the raw word value is also stored. The most
#critical aspect of this class is functions to calculate the prime value of a
#word. This is done by mapping a prime number to each english character in the
#word, then multiplying all the values togeather. This results in a single
#number
#or word prime. Additionally basic POS tagging is used to determine if the word
#is a proper noun.
##
class Word
require 'engtagger'
  private
  @tagger
  PRIMES = {a: 1, b: 2, c: 3, d: 5, e: 7, 
            f: 11, g: 13, h: 17, i: 19, j: 23,
            k: 29, l: 31, m: 37, n: 41, o: 43,
            p: 47, q: 53, r: 59, s: 61, t: 67,
            u: 71, v: 73, w: 79, x: 83, y: 89,
            z: 97}

  public
  @value
  @raw_value
  @tags
  attr_accessor :value
  attr_accessor :raw_value
  attr_accessor :tags


  ##
  #Remove non ascii characters from the word
  ##
  def ascii_fold(word_value)
    word_value.mb_chars
        .normalize(:kd)
        .gsub(/[^\x00-\x7F]/n,'')
  end

  ##
  #Normalize the word, store its non normalized vairants in case some
  #information was lost in the process. Then POS tag the word
  ##
  def initialize(word_value)
    @raw_value = word_value
    @tagger = EngTagger.new
    @tags = @tagger
      .add_tags(ascii_fold(word_value).to_s)
    @value  = ascii_fold(word_value)
             .downcase
             .to_s
  end

  ##
  #Returns a boolean if the word is a proper noun based on its POS tags
  ##
  def is_proper_noun?
    @tags.present? &&
    !@tagger.get_proper_nouns(self.tags).empty? &&
    @tagger.get_proper_nouns(self.tags).keys.first.downcase == self.value
  end

  ##
  #Calculate the word's prime value by mapping each letter to a prime number
  #then multiply them togeather. Returns a single number representing the prime
  ##
  def to_prime
    @word_prime ||=
    self.value
        .split("")
        .inject(1) {|word_prime,letter| PRIMES[letter.intern].present? ? word_prime * PRIMES[letter.intern] : word_prime }
        .to_s
        .intern
  end

end
