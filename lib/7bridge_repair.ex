defmodule BridgeRepair do
  @moduledoc """
  Code for the \"7. Bridge Repair\" problem of the advent of code 2024.
  https://adventofcode.com/2024/day/7

  Solving equations using different operators to repair a bridge,
  with backtracking to find valid solutions.
  """

  def input do
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """
  end

  def get_input(false), do: input()
  def get_input(true), do: File.read!("inputs/bridge_repair.txt")

  def operators, do: [:add, :multiply]
  def operators_part_2, do: [:merge | operators()]

  def parse_input(string) do
    String.split(string, "\n", trim: true)
    |> Enum.map(fn line ->
      equation = String.split(line, ":", trim: true)
      result = String.to_integer(hd(equation))

      terms =
        String.split(Enum.at(equation, 1))
        |> Enum.map(&String.to_integer/1)

      {result, terms}
    end)
  end

  defp backtrack([current_term], expected, operators_acc, _part) do
    # base case
    if current_term == expected do
      {:ok, operators_acc}
    else
      :error
    end
  end

  defp backtrack([current_term, next_term | tail], expected, operators_acc, part) do
    # try each op
    ops = if part == 1, do: operators(), else: operators_part_2()

    Enum.reduce_while(ops, {:error, []}, fn op, acc ->
      new_result = apply_operator(current_term, next_term, op)
      # IO.puts("#{current_result} #{op} #{next_term} = #{new_result}")

      case backtrack([new_result | tail], expected, [op | operators_acc], part) do
        {:ok, result} -> {:halt, {:ok, result}}
        _ -> {:cont, acc}
      end
    end)
  end

  defp apply_operator(a, b, :add), do: a + b
  defp apply_operator(a, b, :multiply), do: a * b

  defp apply_operator(a, b, :merge) do
    (Integer.to_string(a) <> Integer.to_string(b))
    |> String.to_integer()
  end

  defp is_equation_valid?({expected, terms}, part) do
    case backtrack(terms, expected, [], part) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def run1(use_puzzle \\ false) do
    get_input(use_puzzle)
    |> parse_input()
    |> Enum.filter(&is_equation_valid?(&1, 1))
    |> Enum.map(fn {result, _} -> result end)
    |> Enum.sum()
  end

  def run2(use_puzzle \\ false) do
    get_input(use_puzzle)
    |> parse_input()
    |> Enum.filter(&is_equation_valid?(&1, 2))
    |> Enum.map(fn {result, _} -> result end)
    |> Enum.sum()
  end
end
