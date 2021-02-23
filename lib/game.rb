require_relative 'board'

class Game

  PIECE_TYPES_STRING = {
    '♟' => 'Pawn',
    '♜' => 'Rook',
    '♞' => 'Knight',
    '♝' => 'Bishop',
    '♛' => 'Queen',
    '♚' => 'King'
  }

  BOARD_COLUMN_ALPHABET_TO_INTEGER = {
    'a' => 1,
    'b' => 2,
    'c' => 3,
    'd' => 4,
    'e' => 5,
    'f' => 6,
    'g' => 7,
    'h' => 8
  }

  def initialize
    @board = Board.new
    @turn_counter = 1
    @player1_pieces_captured = []
    @player2_pieces_captured = []
    @player1_scores = 0
    @player2_scores = 0
  end

  # Public Functions
  def setup
    @board.setup_board
  end

  def display_board_player2
    @board.display_board_player2
  end

  def start_game
    until @turn_counter == 50
      current_player_string = current_player()
      play('Player 2')
      @turn_counter += 1
    end
  end

  def current_player
    @turn_counter % 2 == 0 ? 'Player 1' : 'Player 2'
  end

  # Get Piece the User would like to move
  def play(player)
    puts 'Enter the row and column of the unit you would like to move'
    # Gets the Row and Column of the Unit that the Player would like to move
    # Append the Row and Column of the Unit into an Array
    piece_location_array = user_row_column_input()

    if valid_player_piece?(piece_location_array) != true
      puts 'Invalid Piece Selected, you have selected an Opponent Piece'
      return play(player)
    end
    
    # Based off the Row and Column of the Unit, find if the unit exists and return the unit
    if player == 'Player 1'
      index = @board.player1.find_index { |unit| unit.location == piece_location_array }
      piece = @board.player1[index]
    end
    if player == 'Player 2'
      index = @board.player2.find_index { |unit| unit.location == piece_location_array }
      piece = @board.player2[index]
    end

    puts 'Enter the location you would like the move the unit to'
    # Get the new Row and Column the Player would like to move the Unit to
    # Append the Row and Column of the Unit into an Array
    new_piece_location_array = user_row_column_input()

    # Get an array of possible locations the Unit can be moved to
    possible_positions = piece.possible_positions

    # Check if the new location the Player would like to move the Unit to is a valid location
    return play(player) unless valid_new_position?(possible_positions, new_piece_location_array)

    if @board.position_occupied_by_same_team?(player, new_piece_location_array) == true
      puts 'Position is occupied by another piece from your team'
      return play(player)
    end

    old_piece_location = piece.location

    piece_type_string = PIECE_TYPES_STRING[piece.type]

    if piece_type_string == 'Pawn'
      if old_piece_location[1] == new_piece_location_array[1]
        if piece_infront_pawn?(old_piece_location, new_piece_location_array) == true
          puts 'Position infront of Pawn is occupied'
          return play(player)
        end
      end
    end

    if piece_type_string == 'Rook'
      if piece_in_between_rook?(old_piece_location, new_piece_location_array) == true
        puts 'Position between Rook is occupied'
        return play(player)
      end
    end

    if piece_type_string == 'Bishop'
      if piece_in_between_bishop?(old_piece_location, new_piece_location_array) == true
        puts 'Position between Bishop is occupied'
        return play(player)
      end
    end

    if piece_type_string == 'Queen'
      if piece_in_between_queen?(old_piece_location, new_piece_location_array) == true
        puts 'Position between Queen is occupied'
        return play(player)
      end
    end

    if piece_type_string != 'Pawn'
      if @board.position_occupied_by_opponent?(piece, new_piece_location_array) == true
        capture_opponent_piece(piece, index, old_piece_location, new_piece_location_array, player)
        @board.display_board_player1
        return display_captured_pieces()
      end
    end

    if piece_type_string == 'Pawn'
      if @board.position_occupied_by_opponent?(piece, new_piece_location_array) == true && piece_exists_diagonally?(old_piece_location, new_piece_location_array) == true
        capture_opponent_piece(piece, index, old_piece_location, new_piece_location_array, player)
        @board.display_board_player1
        return display_captured_pieces()
      end
    end

    # If the location is valid, replace the current location of the Unit with the new location
    puts @board.board[new_piece_location_array[0]][new_piece_location_array[1]]
    if @board.board[new_piece_location_array[0]][new_piece_location_array[1]] == ' '
      move_piece(piece, index, old_piece_location, new_piece_location_array, player)
      @board.display_board_player1
      return display_captured_pieces()
    end
  end

  def move_piece(current_piece, piece_index, old_piece_location_array, new_piece_location_array, current_player)
    @board.board[old_piece_location_array[0]][old_piece_location_array[1]] = ' '
    if current_player == 'Player 1'
      @board.player1[piece_index].location = new_piece_location_array
    else
      @board.player2[piece_index].location = new_piece_location_array
    end
    @board.board[new_piece_location_array[0]][new_piece_location_array[1]] = current_piece.type
  end

  def capture_opponent_piece(current_piece, piece_index, old_piece_location_array, new_piece_location_array, current_player)
    @board.board[old_piece_location_array[0]][old_piece_location_array[1]] = ' '
    @board.board[new_piece_location_array[0]][new_piece_location_array[1]] = current_piece.type

    if current_player == 'Player 1'
      @board.player1[piece_index].location = new_piece_location_array
      opponent_piece_index = @board.player2.find_index { |unit| unit.location == new_piece_location_array }
      opponent_piece = @board.player2[opponent_piece_index]
      @player1_pieces_captured.append(opponent_piece)
      @player1_scores += opponent_piece.points
      @board.player2.delete_at(opponent_piece_index)

    else
      @board.player2[piece_index].location = new_piece_location_array
      opponent_piece_index = @board.player1.find_index { |unit| unit.location == new_piece_location_array }
      opponent_piece = @board.player1[opponent_piece_index]
      @player2_pieces_captured.append(opponent_piece)
      @player2_scores += opponent_piece.points
      @board.player1.delete_at(opponent_piece_index)
    end
  end

  # Function to allow Pawns to Capture other Pieces
  def piece_exists_diagonally?(current_location, new_location)
    # Create a duplicate copy of the Current Location
    copy_of_current_location = current_location.clone

    # Create a duplicate copy of the New Location
    copy_of_new_location = new_location.clone

    # Check if the New Location is directly Diagonal of the Current Location
    if copy_of_current_location[0] + 1 == copy_of_new_location[0] && copy_of_current_location[1] - 1 == copy_of_new_location[1]
      puts copy_of_current_location[0]
      puts copy_of_current_location[1]
      return true if @board.board[copy_of_current_location[0] + 1][copy_of_current_location[1] - 1] != ' '
    end

    if copy_of_current_location[0] + 1 == copy_of_new_location[0] && copy_of_current_location[1] + 1 == copy_of_new_location[1]
      puts copy_of_current_location[0]
      puts copy_of_current_location[1]
      return true if @board.board[copy_of_current_location[0] + 1][copy_of_current_location[1] + 1] != ' '
    end
  end

  # Function to display captured pieces of each player instead of displaying it as an array
  def display_captured_pieces
    puts 'Player 1 Captured Pieces:'
    player1_pieces_captured_string = ''
    @player1_pieces_captured.each do |piece|
      player1_pieces_captured_string << piece.type
    end
    puts player1_pieces_captured_string
    puts 'Player 1 Score:'
    puts @player1_scores
    puts 'Player 2 Captured Pieces:'
    player2_pieces_captured_string = ''
    @player2_pieces_captured.each do |piece|
      player2_pieces_captured_string << piece.type
    end
    puts player2_pieces_captured_string
    puts 'Player 2 Score'
    puts @player2_scores
  end

  # Function to get Row and Column from User and convert it to an array
  def user_row_column_input

    column_row_input = gets.chomp

    column_row_input_array = column_row_input.to_s.split('')

    column_integer = BOARD_COLUMN_ALPHABET_TO_INTEGER[column_row_input_array[0]]

    column_row_input_array.shift

    column_row_input_array.append(column_integer)

    column_row_input_array = column_row_input_array.map(&:to_i)

    column_row_input_array[0] -= 1

    column_row_input_array[1] -= 1

    column_row_input_array

  end

  # User Input Validation Functions
  def integer_validation?(user_input)
    user_input = user_input.to_i
    return true if user_input.between?(0..7)
  end

  def valid_new_position?(possible_positions, new_piece_location)
    possible_positions.each do |position|
      return true if position == new_piece_location
    end
  end

  def piece_infront_pawn?(starting_position, ending_position)
    temporary_piece_starting_position_array = starting_position.clone
    if temporary_piece_starting_position_array[0] < ending_position[0]
      while temporary_piece_starting_position_array[0] != ending_position[0]
        temporary_piece_starting_position_array[0] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end
    end
  end

  def piece_in_between_rook?(starting_position, ending_position)

    # Creates another copy of the piece's current location array
    temporary_piece_starting_position_array = starting_position.clone

    # If the Rook is moved upwards, check every position upwards from
    # the Rook's old location till the Rook's new location
    if temporary_piece_starting_position_array[0] < ending_position[0]
      while temporary_piece_starting_position_array[0] != ending_position[0]
        temporary_piece_starting_position_array[0] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Rook is moved downwards, check every position downwards from
    # the Rook's old location till the Rook's new location
    elsif temporary_piece_starting_position_array[0] > ending_position[0]
      while temporary_piece_starting_position_array[0] != ending_position[0]
        temporary_piece_starting_position_array[0] -= 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Rook is moved to the right, check every position towards the right from
    # the Rook's old location till the Rook's new location
    elsif temporary_piece_starting_position_array[1] < ending_position[1]
      while temporary_piece_starting_position_array[1] != ending_position[1]
        temporary_piece_starting_position_array[1] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Rook is moved to the left, check every position towards the left from
    # the Rook's old location till the Rook's new location
    elsif temporary_piece_starting_position_array[1] > ending_position[1]
      while temporary_piece_starting_position_array[1] != ending_position[1]
        temporary_piece_starting_position_array[1] -= 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end
    end
  end

  def piece_in_between_bishop?(starting_position, ending_position)
    # Creates another copy of the piece's current location array
    temporary_piece_starting_position_array = starting_position.clone

    # If the Bishop is moved upwards diagonally towards the left, check every position upwards diagonally towards
    # the left from the Bishop's old location till the Bishop's new location
    if temporary_piece_starting_position_array[0] < ending_position[0] && temporary_piece_starting_position_array[1] > ending_position[1]
      until temporary_piece_starting_position_array[0] == ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
        temporary_piece_starting_position_array[0] += 1
        temporary_piece_starting_position_array[1] -= 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Bishop is moved upwards diagonally towards the right, check every position upwards diagonally towards
    # the right from the Bishop's old location till the Bishop's new location      
    elsif temporary_piece_starting_position_array[0] < ending_position[0] && temporary_piece_starting_position_array[1] < ending_position[1]
      until temporary_piece_starting_position_array[0] == ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
        temporary_piece_starting_position_array[0] += 1
        temporary_piece_starting_position_array[1] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Bishop is moved downwards diagonally towards the right, check every position downwards diagonally towards
    # the right from the Bishop's old location till the Bishop's new location
    elsif temporary_piece_starting_position_array[0] > ending_position[0] && temporary_piece_starting_position_array[1] < ending_position[1]
      until temporary_piece_starting_position_array[0] == ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
        temporary_piece_starting_position_array[0] -= 1
        temporary_piece_starting_position_array[1] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Bishop is moved downwards diagonally towards the left, check every position downwards diagonally towards
    # the left from the Bishop's old location till the Bishop's new location
    elsif temporary_piece_starting_position_array[0] > ending_position[0] && temporary_piece_starting_position_array[1] > ending_position[1]
      until temporary_piece_starting_position_array[0] == ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
        temporary_piece_starting_position_array[0] -= 1
        temporary_piece_starting_position_array[1] -= 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end
    end
  end

  def piece_in_between_queen?(starting_position, ending_position)
    temporary_piece_starting_position_array = starting_position.clone

    # If the Queen is moved upwards diagonally towards the left, check every position upwards diagonally towards
    # the left from the Queen's old location till the Queen's new location
    if temporary_piece_starting_position_array[0] < ending_position[0] && temporary_piece_starting_position_array[1] > ending_position[1]
      until temporary_piece_starting_position_array[0] == ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
        temporary_piece_starting_position_array[0] += 1
        temporary_piece_starting_position_array[1] -= 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Queen is moved upwards diagonally towards the right, check every position upwards diagonally towards
    # the right from the Queen's old location till the Queen's new location
    elsif temporary_piece_starting_position_array[0] < ending_position[0] && temporary_piece_starting_position_array[1] < ending_position[1]
      until temporary_piece_starting_position_array[0] == ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
        temporary_piece_starting_position_array[0] += 1
        temporary_piece_starting_position_array[1] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Queen is moved downwards diagonally towards the right, check every position downwards diagonally towards
    # the right from the Queen's old location till the Queen's new location
    elsif temporary_piece_starting_position_array[0] > ending_position[0] && temporary_piece_starting_position_array[1] < ending_position[1]
      until temporary_piece_starting_position_array[0] == ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
        temporary_piece_starting_position_array[0] -= 1
        temporary_piece_starting_position_array[1] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    # If the Queen is moved downwards diagonally towards the left, check every position downwards diagonally towards
    # the left from the Queen's old location till the Queen's new location
    elsif temporary_piece_starting_position_array[0] > ending_position[0] && temporary_piece_starting_position_array[1] > ending_position[1]
      until temporary_piece_starting_position_array[0] == ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
        temporary_piece_starting_position_array[0] -= 1
        temporary_piece_starting_position_array[1] -= 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    elsif temporary_piece_starting_position_array[0] < ending_position[0] && temporary_piece_starting_array[1] == ending_position[1]
      while temporary_piece_starting_position_array[0] != ending_position[0]
        temporary_piece_starting_position_array[0] -= 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    elsif temporary_piece_starting_position_array[0] > ending_position[0] && temporary_piece_starting_position_array[1] == ending_position[1]
      while temporary_piece_starting_position_array[1] != ending_position[1]
        temporary_piece_starting_position_array[1] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    elsif temporary_piece_starting_position_array[1] < ending_position[1] && temporary_piece_starting_position_array[0] == ending_position[0]
      while temporary_piece_starting_position_array[1] != ending_position[1]
        temporary_piece_starting_position_array[1] += 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end

    elsif temporary_piece_starting_position_array[1] > ending_position[1] && temporary_piece_starting_position_array[0] == ending_position[0]
      while temporary_piece_starting_position_array[1] != ending_position[1]
        temporary_piece_starting_position_array[1] -= 1
        return true if @board.board[temporary_piece_starting_position_array[0]][temporary_piece_starting_position_array[1]] != ' '
      end
    end
  end

  # Prevent Player from Selecting Opponent Pieces
  def valid_player_piece?(selected_piece_location)
    player = current_player()
    if player == 'Player 1'
      @board.player1.find_index do |unit|
        return true if unit.location == selected_piece_location
      end
    end
    
    if player == 'Player 2'
      @board.player2.find_index do |unit|
        return true if unit.location == selected_piece_location
      end
    end
  end

  # Winning Conditions

  def check?(player, possible_positions)
  end

  def checkmate

  end

end

test = Game.new
test.setup
# p test.current_player_piece
# p test.start_game
p test.play('Player 2')
