require 'json'
require 'open-uri'

class ApplicationController < ActionController::Base
  def new
    @letters = ('A'..'Z').to_a.sample(10)
  end

  def score
    @grid = params[:grid].split(' ')
    @guess = params[:guess].upcase
    url = "https://wagon-dictionary.herokuapp.com/#{@guess}"
    word_serialized = open(url).read
    word = JSON.parse(word_serialized)
    @found = word['found']
    @length = word['length'].to_i

    if in_the_grid?(@guess, @grid) && @found
      @score = @length * @length
      @result = "Congratulations! #{@guess} is a valid English word! Your score is #{@score}."
    elsif in_the_grid?(@guess, @grid)
      @score = 0
      @result = "Sorry but #{@guess} does not seem to be a valid English word... Your score is #{@score}."
    else
      @score = 0
      @result = "Sorry but #{@guess} can't be built out of #{@grid.join(', ')}. Your score is #{@score}."
    end
  end

  def in_the_grid?(attempt, grid)
    if attempt.upcase.chars.all? { |letter| grid.include?(letter) }
      result = 0
      count = Hash.new(0)
      attempt.upcase.each_char { |letter| count[letter] += 1 }
      attempt_hash = Hash[count.sort_by { |_, v| v }.reverse]
      count2 = Hash.new(0)
      grid.each { |letter| count2[letter] += 1 }
      grid_hash = Hash[count2.sort_by { |_, v| v }.reverse]
      attempt_hash.each_key { |k| result += grid_hash[k] - attempt_hash[k] }
      return result >= 0
    end
  end
end
