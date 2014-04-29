require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions

def random_sudoku
    # we're using 9 numbers, 1 to 9, and 72 zeros as an input
    # it's obvious there may be no clashes as all numbers are unique
    # seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
    seed = ((1..9).to_a + Array.new(81-9, 0)).shuffle
    sudoku = Sudoku.new(seed.join)
    # then we solve this (really hard!) sudoku
    sudoku.solve!
    # and give the output to the view as an array of chars
    sudoku.to_s.chars
end

def puzzle(sudoku)
    new_sud = sudoku.dup
    positions = (1..81).to_a.sample(40)
    positions.each do |position| 
      new_sud[position]= ""
    end
    new_sud  
end

  get '/solution' do
    @current_solution = session[:solution]
    puts session[:solution]
    erb :index
  end

  get '/' do
  sudoku = random_sudoku
  session[:solution] = sudoku
  @current_solution = puzzle(sudoku)
  erb :index
  end

  

