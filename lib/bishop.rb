class Bishop
  attr_accessor :location, :team, :type, :points

  def initialize(location, team)
    @location = location
    @team = team
    @type = '♝'
    @points = 3
  end

  BISHOP_MOVES =
  [
    [1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
    [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7],
    [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
    [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]
  ]

  def possible_positions
    possible_positions = []
    BISHOP_MOVES.each do |move|
      new_location = move.zip(@location).map { |x, y| x + y if (x + y).between?(0, 7) }
      possible_positions << new_location unless new_location.include?(nil)
    end
    possible_positions
  end
end
