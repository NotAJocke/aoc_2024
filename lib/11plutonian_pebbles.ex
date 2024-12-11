defmodule PlutonianPebbles do
  @moduledoc """
  Code for the \"11. Plutonian Pebbles\" problem of the advent of code 2024.
  https://adventofcode.com/2024/day/11

  transforming stones in a sequence of iterations,
  based on rules like splitting, multiplying,
  or replacing stones with new ones.
  """

  def input do
    "125 17"
  end

  def get_input(false), do: input()
  def get_input(true), do: File.read!("inputs/plutonian_pebbles.txt")

  def parse(input) do
    input
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  # Slow solution, yeah I tried...
  # def blink([], acc), do: Enum.reverse(List.flatten(acc))

  # def blink([hd | tl], acc) do
  #   blink(tl, [update_pebble(hd) | acc])
  # end

  # def update_pebble(rock) do
  #   cond do
  #     rock == 0 ->
  #       1

  #     rem(n_digits(rock), 2) == 0 ->
  #       split_digits(rock)

  #     true ->
  #       rock * 2024
  #   end
  # end

  # def run1(use_puzzle \\ false) do
  #   stones =
  #     get_input(use_puzzle)
  #     |> parse()

  #   1..25
  #   |> Enum.reduce(stones, fn i, acc ->
  #     IO.puts("Iteration: #{i}")
  #     blink(acc, [])
  #   end)
  #   |> Enum.count()
  # end

  # new solution
  def list_to_map(list) do
    Enum.reduce(list, Map.new(), fn x, acc ->
      Map.update(acc, x, 1, fn y -> y + 1 end)
    end)
  end

  def n_digits(number) do
    number
    |> Integer.digits()
    |> length()
  end

  def split_digits(number) do
    digits = Integer.digits(number)

    mid = div(length(digits), 2)
    left = digits |> Enum.take(mid) |> Integer.undigits()
    right = digits |> Enum.drop(mid) |> Integer.undigits()
    [left, right]
  end

  def blink(stones) do
    for {stone, count} <- stones, reduce: Map.new() do
      acc ->
        cond do
          stone == 0 ->
            Map.update(acc, 1, count, fn x -> x + count end)

          rem(n_digits(stone), 2) == 0 ->
            [left, right] = split_digits(stone)

            acc
            |> Map.update(left, count, fn x -> x + count end)
            |> Map.update(right, count, fn x -> x + count end)

          true ->
            Map.update(acc, stone * 2024, count, fn x -> x + count end)
        end
    end
  end

  def update_stone(stone) do
    cond do
      stone == 0 ->
        1

      rem(n_digits(stone), 2) == 0 ->
        split_digits(stone)

      true ->
        stone * 2024
    end
  end

  def count_stones(stones) do
    for {_, count} <- stones, reduce: 0 do
      acc -> acc + count
    end
  end

  def run1(use_puzzle \\ false) do
    stones =
      get_input(use_puzzle)
      |> parse()
      |> list_to_map()

    1..25
    |> Enum.reduce(stones, fn _, acc ->
      blink(acc)
    end)
    |> count_stones()
  end

  def run2(use_puzzle \\ false) do
    stones =
      get_input(use_puzzle)
      |> parse()
      |> list_to_map()

    1..75
    |> Enum.reduce(stones, fn _, acc ->
      blink(acc)
    end)
    |> count_stones()
  end
end
