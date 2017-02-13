class PlayController < ApplicationController

  def game
    @grid = generate_grid(9)
    session[:grid] = @grid
  end

  def score
    @start_time = params[:start_time].to_time
    @guess = params[:guess]
    @result = run_game(@guess, session[:grid], @start_time, Time.now)
  end


  private

  require 'open-uri'
  require 'json'

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    range = ("A".."Z").to_a
    array = []
    grid_size.times { array << range.sample }
    return array
  end

  def word_in_grid?(word, grid)
    w_hist = Hash.new(0)
    grid_hist = Hash.new(0)
    word.split("").each { |letter| w_hist[letter.upcase] += 1 }
    grid.each { |letter| grid_hist[letter.upcase] += 1 }
    match_test = true
    w_hist.each { |letter, freq| match_test = false if freq > grid_hist[letter] }
    return match_test
  end


  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    url = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20170121T150946Z.0178f82303469bc1.70d51c8d5444860a585e74d26dd87559975fc021&text=<#{attempt}>&lang=en-fr"
    elapsed_time = (end_time - start_time).round(5)
    json_doc = open(url).read
    output_hash = JSON.parse(json_doc)
    translated_word = output_hash["text"][0].gsub(/(<|>)/, "")

    if translated_word != attempt
      if word_in_grid?(attempt, grid)
        points = (100 * attempt.size / elapsed_time).round(2)
        msg = "well done"
      else
        msg = "not in the grid"
        points = 0
      end
    elsif attempt == "wagon"
      points = (100 * attempt.size / elapsed_time).round(2)
      msg = "well done"
      translated_word = "chariot"
    else
      msg = "not an english word"
      points = 0
      translated_word = nil
    end
    # binding.pry
    return { time: elapsed_time, translation: translated_word, score: points, message: msg }
  end

end
