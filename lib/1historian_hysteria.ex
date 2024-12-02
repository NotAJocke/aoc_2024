defmodule HistorianHysteria do
  def input do
    """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """
  end

  def make_two_lists(string) do
    String.split(string, "\n", trim: true)
    |> Enum.reduce({[], []}, fn x, {first_list, last_list} ->
      [first, last] = String.split(x)

      {[String.to_integer(first) | first_list], [String.to_integer(last) | last_list]}
    end)
  end

  def run1(filename \\ nil) do
    input =
      if filename do
        File.read!(filename)
      else
        input()
      end

    {first, last} =
      input
      |> make_two_lists()
      |> then(fn {first, last} -> {Enum.sort(first), Enum.sort(last)} end)

    Enum.zip(first, last)
    |> Enum.map(fn {f, l} -> abs(f - l) end)
    |> Enum.sum()
  end

  def run2(filename \\ nil) do
    input =
      if filename do
        File.read!(filename)
      else
        input()
      end

    {first, last} = make_two_lists(input)

    Enum.map(first, fn x ->
      x * Enum.count(last, fn y -> y == x end)
    end)
    |> Enum.sum()
  end
end
