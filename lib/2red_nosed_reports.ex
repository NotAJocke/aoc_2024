defmodule RedNosedReports do
  @moduledoc """
  Code for the \"2. Red-Nosed Reports\" problem of the advent of code 2024.

  Parsing lists and determine whatever they are safe or not.

  https://adventofcode.com/2024/day/2
  """

  defp input do
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """
  end

  # Parse the input string into a list of lists of integers 
  defp get_reports(string) do
    String.split(string, "\n", trim: true)
    |> Enum.map(fn ln ->
      Enum.map(String.split(ln), &String.to_integer/1)
    end)
  end

  defp is_safe(list), do: is_safe_helper(list, nil, :not_defined)

  defp is_safe_helper(list, previous, trend)

  defp is_safe_helper([], _previous, _trend), do: :safe

  defp is_safe_helper([hd | tl], nil, _trend), do: is_safe_helper(tl, hd, :not_defined)

  defp is_safe_helper([hd | _tl], previous, _trend)
       when abs(previous - hd) < 1 or abs(previous - hd) > 3 do
    :unsafe
  end

  defp is_safe_helper([hd | _tl], previous, :increasing) when previous > hd, do: :unsafe

  defp is_safe_helper([hd | _tl], previous, :decreasing) when previous < hd, do: :unsafe

  defp is_safe_helper([hd | tl], previous, _trend) do
    new_trend = if previous < hd, do: :increasing, else: :decreasing
    is_safe_helper(tl, hd, new_trend)
  end

  defp get_input(nil), do: input()
  defp get_input(filename), do: File.read!(filename)

  defp is_safe_with_one_removal(list) do
    case is_safe(list) do
      :safe ->
        :safe

      :unsafe ->
        list
        |> generate_subarrays()
        |> Enum.any?(&(is_safe(&1) == :safe))
        |> (fn safe_found -> if safe_found, do: :safe, else: :unsafe end).()
    end
  end

  defp generate_subarrays(list) do
    Enum.map(0..(length(list) - 1), fn i -> List.delete_at(list, i) end)
  end

  @doc """
  Run the part 1 solution.

  Determine which list is safe or not
  """
  def run1(filename \\ nil) do
    get_input(filename)
    |> get_reports
    |> Enum.map(&is_safe/1)
    |> Enum.count(fn x -> x == :safe end)
  end

  @doc """
  Run the part 2 solution

  In part 2, some list that were unsafe 
  can now be safe
  """
  def run2(filename \\ nil) do
    get_input(filename)
    |> get_reports()
    |> Enum.map(&is_safe_with_one_removal/1)
    |> Enum.count(fn x -> x == :safe end)
  end
end
