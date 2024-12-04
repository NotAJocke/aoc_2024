defmodule MullItOver do
  @moduledoc """
  Code for the \"3. Mull It Over\" problem of the advent of code 2024. 
  https://adventofcode.com/2024/day/3

  Parsing multiplication instructions, along with other valid 
  and invalid instructions, and executing them.
  """

  defp input do
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
  end

  defp get_input(nil), do: input()
  defp get_input(filename), do: File.read!(filename)

  defp parse_multiplications(string) do
    Regex.scan(~r/mul\(\d+,\d+\)/, string)
    |> Enum.map(&hd/1)
  end

  defp parse_multiplications_and_does(string) do
    Regex.scan(~r/mul\(\d+,\d+\)|do\(\)|don't\(\)/, string)
    |> Enum.map(&hd/1)
  end

  defp make_multiplications(factors) do
    Enum.reduce(factors, fn x, acc ->
      x * acc
    end)
  end

  def extract_numbers(match) do
    Regex.scan(~r/\d+/, match)
    |> Enum.map(fn [number] -> String.to_integer(number) end)
  end

  def keep_enabled_multiplications(list) do
    Enum.reduce(list, {[], true}, fn
      "do()", {acc, _enabled} -> {acc, true}
      "don't()", {acc, _enabled} -> {acc, false}
      x, {acc, true} -> {[x | acc], true}
      _x, {acc, false} -> {acc, false}
    end)
    |> elem(0)
  end

  def run1(filename \\ nil) do
    get_input(filename)
    |> parse_multiplications()
    |> Enum.map(&extract_numbers/1)
    |> IO.inspect()
    |> Enum.map(&make_multiplications/1)
    |> Enum.sum()
  end

  def run2(filename \\ nil) do
    get_input(filename)
    |> parse_multiplications_and_does()
    |> keep_enabled_multiplications()
    |> Enum.map(&extract_numbers/1)
    |> Enum.map(&make_multiplications/1)
    |> Enum.sum()
  end
end
