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
    prepare_to_check_solution
    generate_new_puzzle_if_necessary
    @current_solution = session[:current_solution] || session[:puzzle]
    @solution = session[:solution]
    @puzzle = session[:puzzle]  
    erb :index
  end

  post '/' do
    cells = box_order_to_row_order(params["cell"])
    session[:current_solution] = cells.map{ |value| value.to_i  }.join
    session[:check_solution] = true
    redirect to("/")
  end

def box_order_to_row_order(cells)
  boxes = cells.each_slice(9).to_a
  (0..8).to_a.inject([]) {|memo, i|
  first_box_index = i / 3 * 3
  three_boxes = boxes[first_box_index, 3]
  three_rows_of_three = three_boxes.map do |box|
    row_number_in_a_box = i % 3
    first_cell_in_the_row_index = row_number_in_a_box * 3 
  end
    box[first_cell_in_the_row_index, 3]
    memo += three_rows_of_three.flatten
  }
end

  def generate_new_puzzle_if_necessary
    return if session[:current_solution]
    sudoku = random_sudoku
    session[:solution] = sudoku
    session[:puzzle] = puzzle(sudoku)
    session[:current_solution] = session[:puzzle]
  end
  
  def prepare_to_check_solution
    @check_solution = session[:check_solution]
    session[:check_solution] = nil
  end

  helpers do

  def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value) 
    must_be_guessed = puzzle_value == 0
    tried_to_guess = current_solution_value.to_i != 0
    guessed_incorrectly = current_solution_value != solution_value
      if solution_to_check &&
           must_be_guessed &&
           tried_to_guess &&
           guessed_incorrectly
           'incorrect'
      elsif !must_be_guessed
        'value-provided'
      end
    end
  
  
  def cell_value(value)
    value.to_i == 0 ? '' : value
  end
end           




