
class Rook
  attr_accessor :moved, :location, :team, :type, :points

  def initialize(location, team)
    @moved = false
    @location = location
    @team = team
    @type = '♜'
    @points = 5
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
end
