defmodule GuardGallivant do
  @moduledoc """
  Code for the \"6. Guard Gallivant\" problem of the advent of code 2024.
  https://adventofcode.com/2024/day/6

  Simulating a guard's movement on a map with obstacles,
  detecting loops and adjusting paths accordingly.
  """

  def input do
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """
  end

  def get_input(nil), do: input()
  def get_input(filename), do: File.read!(filename)

  def parse_map(string) do
    string
    |> String.split("\n", trim: true)
  end

  def is_guard(char), do: char in ["^", "v", "<", ">"]

  def guard_orientation(char) do
    case char do
      "^" -> :up
      "v" -> :down
      "<" -> :left
      ">" -> :right
    end
  end

  def find_guard(map) do
    Enum.with_index(map)
    |> Enum.find_value(fn {row, row_idx} ->
      case String.graphemes(row)
           |> Enum.with_index()
           |> Enum.find(fn {char, _} -> is_guard(char) end) do
        nil -> nil
        {char, col_idx} -> {col_idx, row_idx, guard_orientation(char)}
      end
    end)
  end

  def translate_pos(:up, x, y), do: {x, y - 1}
  def translate_pos(:down, x, y), do: {x, y + 1}
  def translate_pos(:left, x, y), do: {x - 1, y}
  def translate_pos(:right, x, y), do: {x + 1, y}

  def within_bounds?(map, x, y) do
    y >= 0 and y < length(map) and x >= 0 and x < String.length(Enum.at(map, y))
  end

  def next_guard_move(map, {x, y, direction}, {acc, visited}) do
    visited = MapSet.new(visited)
    loop(map, {x, y, direction}, {acc, visited})
  end

  defp loop(map, {x, y, direction}, {acc, visited}) do
    {new_x, new_y} = translate_pos(direction, x, y)

    cond do
      not within_bounds?(map, new_x, new_y) ->
        {acc, MapSet.to_list(visited)}

      MapSet.member?(visited, {new_x, new_y}) ->
        loop(map, {new_x, new_y, direction}, {acc, visited})

      true ->
        char = String.at(Enum.at(map, new_y), new_x)

        case char do
          "#" ->
            loop(map, {x, y, rotate_90(direction)}, {acc, visited})

          _ ->
            loop(map, {new_x, new_y, direction}, {acc + 1, MapSet.put(visited, {new_x, new_y})})
        end
    end
  end

  def rotate_90(:up), do: :right
  def rotate_90(:down), do: :left
  def rotate_90(:left), do: :up
  def rotate_90(:right), do: :down

  def next_move_with_loop_detection(map, {x, y, direction}, {objX, objY}, visited) do
    {new_x, new_y} = translate_pos(direction, x, y)

    cond do
      not within_bounds?(map, new_x, new_y) ->
        :ended

      MapSet.member?(visited, {new_x, new_y, direction}) ->
        :loop

      true ->
        char = String.at(Enum.at(map, new_y), new_x)

        cond do
          new_x == objX and new_y == objY ->
            next_move_with_loop_detection(
              map,
              {x, y, rotate_90(direction)},
              {objX, objY},
              visited
            )

          char == "#" ->
            next_move_with_loop_detection(
              map,
              {x, y, rotate_90(direction)},
              {objX, objY},
              visited
            )

          true ->
            next_move_with_loop_detection(
              map,
              {new_x, new_y, direction},
              {objX, objY},
              MapSet.put(visited, {new_x, new_y, direction})
            )
        end
    end
  end

  def run1(filename \\ nil) do
    map = get_input(filename) |> parse_map()
    {x, y, dir} = find_guard(map)
    {acc, _} = next_guard_move(map, {x, y, dir}, {1, [{x, y}]})
    acc
  end

  def run2(filename \\ nil) do
    map =
      get_input(filename)
      |> parse_map()

    {x, y, dir} = find_guard(map)

    {mapXLength, mapYLength} = {String.length(Enum.at(map, 0)), length(map)}

    obstacles =
      for objY <- 0..(mapYLength - 1),
          objX <- 0..(mapXLength - 1),
          objX != x or objY != y,
          do: {objX, objY}

    # Using Task.async_stream to parallelize
    obstacles
    |> Task.async_stream(
      fn {objX, objY} ->
        next_move_with_loop_detection(map, {x, y, dir}, {objX, objY}, MapSet.new([{x, y, dir}]))
      end,
      max_concurrency: System.schedulers_online()
    )
    |> Enum.filter(fn {:ok, result} -> result == :loop end)
    |> Enum.count()
  end
end
