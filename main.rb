require_relative 'utils'
require 'byebug'

class Wasd2048
  @board
  def initialize
    @board = Array.new(4) { Array.new(4) }
    new_num_popup!
    new_num_popup!
  end

  def new_num_popup!
    loop do
      xy = rand(16).divmod(4)
      break if @board[xy[0]][xy[1]].nil? && @board[xy[0]][xy[1]] = two_or_four
    end
  end

  def two_or_four
    2 + rand(2)*2
  end

  def to_s
    str = @board.map do |arr|
      arr.map { |chr| "____#{chr}"[-4..-1] }.join('|')
    end
    str.join("\n")
  end

  def show
    clear_screen!
    move_to_home!
    puts to_s
  end
end

game = Wasd2048.new

game.show

# while true
#   input = gets.chomp
#
#   case input.downcase
#   when 'w'
#     puts 'W'
#   when 'a'
#     puts 'A'
#   when 's'
#     puts 'S'
#   when 'd'
#     puts 'D'
#   when 'q'
#     break
#   else
#     puts 'W(up)-A(left)-S(down)-D(right)-Q(quit)'
#   end
# end
