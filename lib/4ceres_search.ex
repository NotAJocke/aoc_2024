defmodule CeresSearch do
  @moduledoc """
  Code for the \"4. Ceres Search\" problem of the advent of code 2024.
  https://adventofcode.com/2024/day/4

  Part1. Parsing a char matrix and finding all the occurences of 'XMAS' in all directions
  Example:

    ....XXMAS.
    .SAMXMS...
    ...S..A...
    ..A.A.MS.X
    XMASAMX.MM
    X.....XA.A
    S.S.S.S.SS
    .A.A.A.A.A
    ..M.M.M.MM
    .X.X.XMASX

    Top -> Bot: (3;9)                        - 1
    Bot -> Top: (4;6) (9;9)                  - 2
    Left -> Right (0;5) (4;0) (9;5)          - 3
    Right -> Left (1;4) (4;6)                - 2
    Diag TL -> BR (0;4)                      - 1
    Diag TR -> BL (3;9)                      - 1
    Diag BR -> TL (9; 9) (9;6) (9;4) (5;6)   - 4
    Diag BL -> TR (9;1) (9;3) (9;5) (5;0)    - 4

    Total                                    - 18

  Part2. Parsing a char matrix and finding all the X-MAS
  Example:

    M.S
    .A.
    M.S
  """

  defp input do
    """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """
  end

  defp get_input(nil), do: input()
  defp get_input(filename), do: File.read!(filename)

  defp parse_into_matrix(string) do
    String.split(string, "\n", trim: true)
    |> Enum.map(&List.to_tuple(String.graphemes(&1)))
    |> List.to_tuple()
  end

  defp matrix_index(matrix, x, y), do: elem(elem(matrix, y), x)

  # PART 1
  defp search_word_in_matrix(matrix, word) do
    directions = [
      # Right
      {1, 0},
      # Left
      {-1, 0},
      # Down
      {0, 1},
      # Up
      {0, -1},
      # Diagonal down-right
      {1, 1},
      # Diagonal up-left
      {-1, -1},
      # Diagonal up-right
      {1, -1},
      # Diagonal down-left
      {-1, 1}
    ]

    {max_x, max_y} = {tuple_size(elem(matrix, 0)), tuple_size(matrix)}

    for y <- 0..(max_y - 1),
        x <- 0..(max_x - 1),
        {dx, dy} <- directions,
        search_in_direction?(matrix, {max_x, max_y}, x, y, dx, dy, word),
        reduce: [] do
      acc -> [{x, y, dx, dy} | acc]
    end
  end

  defp search_in_direction?(matrix, {max_x, max_y}, x, y, dx, dy, word) do
    word_length = String.length(word)

    Enum.all?(0..(word_length - 1), fn i ->
      nx = x + i * dx
      ny = y + i * dy

      # Check bounds and character match
      if nx < 0 or nx >= max_x or ny < 0 or ny >= max_y do
        false
      else
        matrix_index(matrix, nx, ny) == String.at(word, i)
      end
    end)
  end

  def run1(filename \\ nil) do
    get_input(filename)
    |> parse_into_matrix()
    |> search_word_in_matrix("XMAS")
    |> Enum.count()
  end

  # PART 2
  defp find_As_in_matrix(matrix) do
    {max_x, max_y} = {tuple_size(elem(matrix, 0)), tuple_size(matrix)}

    for y <- 0..(max_y - 1),
        x <- 0..(max_x - 1),
        matrix_index(matrix, x, y) == "A",
        reduce: [] do
      acc -> [check_cross(matrix, {max_x, max_y}, x, y) | acc]
    end
  end

  defp check_cross(matrix, {max_x, max_y}, x, y) do
    valid_words = [["M", "A", "S"], ["S", "A", "M"]]

    offsets = [
      down_right: [{-1, -1}, {0, 0}, {1, 1}],
      up_right: [{-1, 1}, {0, 0}, {1, -1}]
    ]

    valid_word? = fn word -> Enum.member?(valid_words, word) end

    diagonal_valid? = fn offsets_list ->
      offsets_list
      |> Enum.map(fn {dx, dy} ->
        new_x = x + dx
        new_y = y + dy

        if new_x < 0 or new_x >= max_x or new_y < 0 or new_y >= max_y do
          :error
        else
          matrix_index(matrix, new_x, new_y)
        end
      end)
      |> Enum.filter(fn x -> x != :error end)
      |> valid_word?.()
    end

    diagonal_valid?.(offsets[:down_right]) and diagonal_valid?.(offsets[:up_right])
  end

  def run2(filename \\ nil) do
    get_input(filename)
    |> parse_into_matrix()
    |> find_As_in_matrix()
    |> Enum.filter(& &1)
    |> Enum.count()
  end
end
