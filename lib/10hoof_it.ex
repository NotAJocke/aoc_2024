defmodule HoofIt do
  @moduledoc """
  Code for the \"10. Hoof It\" problem of the advent of code 2024.
  https://adventofcode.com/2024/day/10

  Finding and scoring valid trails formed by consecutive numbers on a grid.
  """

  def input do
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """
  end

  def get_input(false), do: input()
  def get_input(true), do: File.read!("inputs/hoof_it.txt")

  # part 1
  def find_valid_trail(matrix, {x, y}, current_number, path \\ []) do
    cond do
      not Matrix.in_bounds?(matrix, x, y) ->
        []

      Matrix.get_at(matrix, x, y) != current_number ->
        []

      Matrix.get_at(matrix, x, y) == 9 ->
        [{x, y}]

      true ->
        neighbors = [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

        neighbors
        |> Enum.flat_map(fn neighbor ->
          find_valid_trail(matrix, neighbor, current_number + 1, [{x, y} | path])
        end)
    end
  end

  def find_trailhead_score(list) do
    list
    # Part 2
    # |> Enum.reduce(MapSet.new(), fn x, acc ->
    #   MapSet.put(acc, x)
    # end)
    |> Enum.count()
  end

  def find_all_trailhead(matrix) do
    {max_x, max_y} = matrix.size

    for y <- 0..(max_y - 1), x <- 0..(max_x - 1), reduce: 0 do
      acc ->
        if Matrix.get_at(matrix, x, y) == 0 do
          score =
            find_valid_trail(matrix, {x, y}, 0, [])
            |> find_trailhead_score()

          acc + score
        else
          acc
        end
    end
  end

  def run1(use_puzzle \\ false) do
    get_input(use_puzzle)
    |> Matrix.parse(:int)
    |> find_all_trailhead()
  end

  def run2(use_puzzle \\ false) do
    get_input(use_puzzle)
    |> Matrix.parse(:int)
    |> find_all_trailhead()
  end
end
