class Rook
  attr_accessor :location, :rook_number, :team, :type

  def initialize(location, rook_number, team)
    @location = location
    @rook_number = rook_number
    @team = team
    @type = '♜'
  end

  def possible_positions
    possible_positions = []
    x_move = [1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7]
    y_move = [1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7]
    current_location = @location
    x_move.each do |x|
      new_location = current_location[0] + x
      if (0..7).include?(new_location)
        possible_positions << [new_location, current_location[1]]
      end
    end
    y_move.each do |y|
      new_location = current_location[1] + y
      if (0..7).include?(new_location)
        possible_positions << [current_location[0], new_location]
      end
    end
    possible_positions
  end

  def piece_in_between?(starting_position, ending_position)
    if starting_position[0] < ending_position[0]
      while starting_position[0] != ending_position[0]
        starting_position[0] += 1
        return true if @board[starting_position[0]][starting_position[1]] != ' '
      end
    elsif starting_position[0] > ending_position[0]
      while starting_position[0] != ending_position[0]
        starting_position[0] -= 1
        return true if @board[starting_position[0]][starting_position[1]] != ' '
      end
    elsif starting_position[1] < ending_position[1]
      while starting_position[1] != ending_position[0]
        starting_position[1] += 1
        return true if @board[starting_position[1]][starting_position[1]] != ' '
      end
    elsif starting_position[1] > ending_position[1]
      while starting_position[1] != ending_position[0]
        starting_position[1] -= 1
        return true if @board[starting_position[1]][starting_position[1]] != ' '
      end
    end
  end
end
