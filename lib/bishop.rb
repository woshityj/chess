class Bishop
  attr_accessor :location, :bishop_number, :team, :type, :points

  def initialize(location, bishop_number, team)
    @location = location
    @bishop_number = bishop_number
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

test = Bishop.new([3, 3], 0, 'white')
p test.possible_positions
