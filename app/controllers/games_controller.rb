require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ("A".."Z").to_a.sample(20)
    session[:score] = 0 if session[:score].nil?
  end

  def score
    @word = params[:word].downcase
    @letters = params[:letters].downcase.gsub(" ", "").chars
    # if (@word.chars - @letters).length > 0
    if in_grid(@word.chars, @letters) == false
      @result = "It needs to be on the grid"
    elsif english?(@word) == false
      @result = 'It is not an english word'
    else
      @result = 'It is an english word; Congrats'
      session[:score] += 1
    end
  end

  def english?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    response = open(url).read
    result = JSON.parse(response)
    result["found"]
  end

  def letter_frequency(word)
    my_hash = {}
    word.each do |letter|
      if my_hash[letter].nil?
        my_hash[letter] = 1
      else
        my_hash[letter] += 1
      end
    end
    my_hash
  end

  def in_grid(word, letters)
    word_hash = letter_frequency(word)
    letters_hash = letter_frequency(letters)
    result = true
    word_hash.each do |key, value|
      result = false if  letters_hash[key].nil? || value > letters_hash[key]
    end
    result
  end

  private

  def current_user
    @_current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end

end
