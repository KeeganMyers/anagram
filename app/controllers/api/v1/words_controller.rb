class Api::V1::WordsController < ApplicationController
  before_action :set_word,only: [:show, :destroy, :destroy_group]
  before_action :set_limit,only: [:show]
  before_action :set_proper_nouns,only: [:show]

  def show
    render json: {anagrams: Dictionary.find(@word,@limit, @allow_proper_nouns)}.to_json
  end

  def test_anagrams
    render json: {anagrams: Dictionary.are_anagrams?(params[:words])}.to_json
  end

  def largest_group
    render json: {anagrams: Dictionary.largest_group}.to_json
  end

  def show_by_group_size
    render json: {anagram_groups: Dictionary.groups_with_size(params[:size].to_i)}.to_json
  end

  def create
    params[:words].each do |word_string|
      word = Word.new(word_string)
      Dictionary.append(word)
    end
    head 201
  end

  def destroy
    if Dictionary.remove_word(@word)
      head 204
    else
      head 405
    end
  end


  def destroy_group
    if Dictionary.remove_group(@word)
      head 204
    else
      head 405
    end
  end

  def clear
    Dictionary.clear
    head 204
  end

  def stats
    render json: {count: Dictionary.word_count,
     min: Dictionary.shortest_word,
     max: Dictionary.longest_word,
     median: Dictionary.median_word,
     average: Dictionary.average_word_length}.to_json
  end

  private
    def set_word
      @word = params[:word].present? ? Word.new(params[:word]) : nil
    end

    def set_limit
      @limit = params[:limit].present? ? params[:limit].to_i : nil
    end

    def set_proper_nouns
      @allow_proper_nouns = params[:proper_nouns].present? ? params[:proper_nouns] == '1'  : true
    end

    def word_params
      params.fetch(:word,nil)
      params.fetch(:limit,nil)
    end
end
