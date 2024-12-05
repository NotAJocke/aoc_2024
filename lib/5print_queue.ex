defmodule PrintQueue do
  @moduledoc """
  Code for the \"5. Print Queue\" problem of the advent of code 2024.
  https://adventofcode.com/2024/day/5

  Parsing a document with rules and lists, and ensuring rules are valid
  if not, correct them
  """

  def input do
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  end

  def get_input(nil), do: input()
  def get_input(filename), do: File.read!(filename)

  def parse_rules(raw_rules) do
    Enum.map(raw_rules, fn rule ->
      rule
      |> String.split("|", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def parse_updates(raw_updates) do
    Enum.map(raw_updates, fn update ->
      update
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def parse_document(string) do
    [raw_rules, raw_updates] =
      string
      |> String.split("\n\n")
      |> Enum.map(&String.split(&1, "\n", trim: true))

    {parse_rules(raw_rules), parse_updates(raw_updates)}
  end

  def update_valid?([], _rules), do: true
  def update_valid?([_hd | []], _rules), do: true

  def update_valid?([hd, sn | tail], rules) do
    ban_pattern = [sn, hd]

    if Enum.member?(rules, ban_pattern) do
      false
    else
      update_valid?([sn | tail], rules)
    end
  end

  def get_element_at_center(list) do
    index = div(length(list), 2)

    Enum.at(list, index)
  end

  def fix_invalid_update([], _rules, {acc, has_changed}), do: {Enum.reverse(acc), has_changed}

  def fix_invalid_update([hd | []], _rules, {acc, has_changed}),
    do: {Enum.reverse([hd | acc]), has_changed}

  def fix_invalid_update([hd, sn | tail], rules, {acc, has_changed}) do
    ban_pattern = [sn, hd]

    if Enum.member?(rules, ban_pattern) do
      fix_invalid_update(tail, rules, {[hd, sn | acc], true})
    else
      fix_invalid_update([sn | tail], rules, {[hd | acc], has_changed})
    end
  end

  def fix_update_while_invalid(update, rules) do
    helper = fn helper, update, rules ->
      {fixed_update, has_changed} = fix_invalid_update(update, rules, {[], false})

      if has_changed do
        helper.(helper, fixed_update, rules)
      else
        fixed_update
      end
    end

    helper.(helper, update, rules)
  end

  def run1(filename \\ nil) do
    {rules, updates} =
      filename
      |> get_input()
      |> parse_document()

    updates
    |> Enum.filter(&update_valid?(&1, rules))
    |> Enum.map(&get_element_at_center/1)
    |> Enum.sum()
  end

  def run2(filename \\ nil) do
    {rules, updates} =
      filename
      |> get_input()
      |> parse_document()

    updates
    |> Enum.reject(&update_valid?(&1, rules))
    |> Enum.map(&fix_update_while_invalid(&1, rules))
    |> Enum.map(&get_element_at_center/1)
    |> Enum.sum()
  end
end
