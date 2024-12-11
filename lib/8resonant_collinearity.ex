defmodule ResonantCollinearity do
  @moduledoc """
  Code for the \"8. Resonant Collinearity\" problem of the advent of code 2024.
  https://adventofcode.com/2024/day/8

  Analyzing and finding possible antenna positions and their collinearity,
  while detecting and processing possible resonance interactions between them.
  """

  def input do
    """
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
    """
  end

  def input2 do
    """
    T....#....
    ...T......
    .T....#...
    .........#
    ..#.......
    ..........
    ...#......
    ..........
    ....#.....
    ..........
    """
  end

  def get_input(false), do: input()
  def get_input(true), do: File.read!("inputs/resonant_collinearity.txt")

  def find_antennas_per_frequency(matrix) do
    {max_x, max_y} = matrix.size

    for x <- 0..(max_x - 1), y <- 0..(max_y - 1), reduce: %{} do
      acc ->
        char = Matrix.get_at(matrix, x, y)

        if char != "." and char != "#" do
          Map.update(acc, char, [{x, y}], &[{x, y} | &1])
        else
          acc
        end
    end
  end

  def get_antinodes({ax, ay}, {bx, by}) do
    {dx, dy} = {bx - ax, by - ay}

    [{ax - dx, ay - dy}, {bx + dx, by + dy}]
  end

  def get_antinodes_p2(matrix, {ax, ay}, {bx, by}) do
    {dx, dy} = {bx - ax, by - ay}

    pos = {ax - dx, ay - dy}

    prevs = get_prev_antinode(matrix, pos, {dx, dy}, [])
    nexts = get_next_antinode(matrix, {ax, ay}, {dx, dy}, [])

    prevs ++ nexts
  end

  def get_prev_antinode(matrix, {x, y}, {dx, dy}, acc) do
    if Matrix.in_bounds?(matrix, x, y) do
      get_prev_antinode(matrix, {x - dx, y - dy}, {dx, dy}, [{x, y} | acc])
    else
      acc
    end
  end

  def get_next_antinode(matrix, {x, y}, {dx, dy}, acc) do
    if Matrix.in_bounds?(matrix, x, y) do
      get_next_antinode(matrix, {x + dx, y + dy}, {dx, dy}, [{x, y} | acc])
    else
      acc
    end
  end

  def antennas_combinations(antennas) do
    for {x, i} <- Enum.with_index(antennas),
        {y, j} <- Enum.with_index(antennas),
        i < j,
        do: {x, y}
  end

  def find_antinodes(combinations, matrix) do
    combinations
    |> Enum.flat_map(fn {a, b} ->
      get_antinodes(a, b)
      |> Enum.filter(fn {x, y} -> Matrix.in_bounds?(matrix, x, y) end)
    end)
    |> MapSet.new()
  end

  def find_antinodes_p2(combinations, matrix) do
    combinations
    |> Enum.flat_map(fn {a, b} ->
      get_antinodes_p2(matrix, a, b)
    end)
    |> MapSet.new()
  end

  def run1(use_puzzle \\ false) do
    matrix =
      get_input(use_puzzle)
      |> Matrix.parse(:string)

    find_antennas_per_frequency(matrix)
    |> Enum.reduce(MapSet.new(), fn {k, antennas}, acc ->
      antennas
      |> antennas_combinations()
      |> find_antinodes(matrix)
      |> IO.inspect(label: k)
      |> MapSet.union(acc)
    end)
    |> Enum.count()
  end

  def run2(use_puzzle \\ false) do
    matrix =
      get_input(use_puzzle)
      |> Matrix.parse(:string)

    find_antennas_per_frequency(matrix)
    |> IO.inspect()
    |> Enum.reduce(MapSet.new(), fn {k, antennas}, acc ->
      antennas
      |> antennas_combinations()
      |> IO.inspect(label: k)
      |> find_antinodes_p2(matrix)
      |> IO.inspect(label: k)
      |> MapSet.union(acc)
      |> IO.inspect(label: k)
    end)
    |> Enum.count()
  end
end
