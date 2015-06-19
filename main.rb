require_relative 'utils'
require 'byebug'

FOUR = 4

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
      arr[PAIR_1] = no_gap_sum(arr[PAIR_1])
      arr[PAIR_2] = no_gap_sum(arr[PAIR_2])
      arr[PAIR_3] = no_gap_sum(arr[PAIR_3])

      arr[SET_L] = one_gap_sum(arr[SET_L])
      arr[SET_R] = one_gap_sum(arr[SET_R])

      arr        = two_gap_sum(arr)

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

  def show
    # clear_screen!
    # move_to_home!
    # debugger
    puts to_s
    puts
  end

  private

    def no_gap_sum(duet)
      return duet if duet.none?
      duet.first == duet.last ? [duet.reduce(:+), nil] : duet
    end

    def one_gap_sum(trio)
      return trio if trio.none? || !trio[MID].nil?
      trio = trio.map { |no| no.nil? ? 0 : no }
      trio = trio.first == trio.last ? [trio.reduce(:+), nil, nil] : trio
      trio.map { |no| no == 0 ? nil : no }
    end

    def two_gap_sum(quad)
      return quad if quad.none? || !quad[MID2].nil?
      quad = quad.map { |no| no.nil? ? 0 : no }
      quad = quad.first == quad.last ? [quad.reduce(:+), nil, nil, nil] : quad
      quad.map { |no| no == 0 ? nil : no }
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
        xy = rand(16).divmod(FOUR)
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

    def trans_s
      str = @board.transpose.map do |arr|
        arr.map { |chr| "____#{chr}"[-4..-1] }.join('|')
      end
      str.join("\n")
    end
end

game = Wasd2048.new

while true
  game.show
  input = gets.chomp
  debugger
  case input.downcase
  when 'w'
    game.stack_to_top
  when 'a'
    game.stack_to_left
  when 'r'
    game.stack_to_bottom
  when 's'
    game.stack_to_right
  when 'q'
    break
  else
    puts 'W(up)-A(left)-S(down)-D(right)-Q(quit)'
  end
end

game.show
