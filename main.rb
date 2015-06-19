require_relative 'utils'
require 'byebug'

FOUR = 4
BLOCK = FOUR*FOUR

PAIR_1 = (0..1)
PAIR_2 = (1..2)
PAIR_3 = (2..3)

SET_L = (0..2)
SET_R = (1..3)

MID  = 1
MID2 = (1..2)

class Wasd2048
  @board

  def initialize
    @board = Array.new(FOUR) { Array.new(FOUR) }
    new_num_popup!
    new_num_popup!
  end

  def stack_to_left
    before_stack = Marshal.load( Marshal.dump(@board) )

    @board.map do |arr|
      arr[PAIR_1] = marry(arr[PAIR_1])
      arr[PAIR_2] = marry(arr[PAIR_2])
      arr[PAIR_3] = marry(arr[PAIR_3])

      arr[SET_L] = marry(arr[SET_L])
      arr[SET_R] = marry(arr[SET_R])

      arr.replace(marry(arr))

      len = arr.compact.size
      arr.compact! unless len == FOUR
      (FOUR - len).times { arr << nil }
    end

    new_num_popup! unless before_stack == @board
  end

  def stack_to_right
    horrizontal_mirror!
    stack_to_left
    horrizontal_mirror!
  end

  def stack_to_top
    anticlock_rotate!
    stack_to_left
    clockwise_rotate!
  end

  def stack_to_bottom
    clockwise_rotate!
    stack_to_left
    anticlock_rotate!
  end

  def has_2048?
    !!@board.flatten.find { |f| f == 2048 }
  end

  def is_over?
    return false if @board.flatten.compact.count < BLOCK

    before_stack = Marshal.load( Marshal.dump(@board) )
    return false if stack_to_left && before_stack != @board
    return false if stack_to_right && before_stack != @board
    return false if stack_to_top && before_stack != @board
    return false if stack_to_bottom && before_stack != @board
    return true
  end

  def show
    clear_screen!
    move_to_home!
    puts to_s
    puts
  end

  private

    def marry(pair)
      size = pair.size
      in_between = (1..size-2)
      return pair if pair.none? || pair.compact.size != 2
      return pair if size > 2 && !pair[in_between].none?

      print_nil = size - 1
      if pair.first == pair.last
        pair = [pair.compact.reduce(:+)] + Array.new(print_nil, nil)
      end
      pair
    end

    def horrizontal_mirror!
      @board.map { |arr| arr.reverse! }
    end

    def anticlock_rotate!
      horrizontal_mirror!
      @board = @board.transpose
    end

    def clockwise_rotate!
      anticlock_rotate!
      anticlock_rotate!
      anticlock_rotate!
    end

    def new_num_popup!
      loop do
        xy = rand(BLOCK).divmod(FOUR)
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
end

game = Wasd2048.new
game.show

while true
  input = gets.chomp

  case input.downcase[0]
  when 'w'
    game.stack_to_top
  when 'a'
    game.stack_to_left
  when 's'
    game.stack_to_bottom
  when 'd'
    game.stack_to_right
  when 'q'
    break
  else
    puts 'W(up)-A(left)-S(down)-D(right)-Q(quit)'
  end
  game.show

  if game.has_2048?
    puts 'YOU WIN'
    break
  elsif game.is_over?
    puts 'YOU LOSE'
    break
  end
end
