defmodule DiskFragmenter do
  @moduledoc """
  Code for the \"9. Disk Fragmenter\" problem of the advent of code 2024.
  https://adventofcode.com/2024/day/9

  Simulating the process of decompressing and optimizing disk space,
  with operations for moving and calculating checksums based on
  file fragment positions.
  """

  def input do
    "2333133121414131402"
  end

  def get_input(false), do: input()
  def get_input(true), do: File.read!("inputs/disk_fragmenter.txt")

  def parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  def decompress(list), do: decompress(list, 0, 0, 0, [])

  def decompress([], _index, id, empty, acc) do
    data = List.to_tuple(Enum.reverse(acc))

    %{
      data: data,
      size: tuple_size(data),
      empty: empty,
      last_id: id - 1
    }
  end

  def decompress([0 | tail], index, id, empty, acc) do
    decompress(tail, index + 1, id, empty, acc)
  end

  def decompress([hd | tail], index, id, empty, acc) do
    shot =
      Enum.reduce(0..(hd - 1), [], fn _x, lacc ->
        if rem(index, 2) == 0 do
          [id | lacc]
        else
          ["." | lacc]
        end
      end)

    if rem(index, 2) == 0 do
      decompress(tail, index + 1, id + 1, empty, shot ++ acc)
    else
      decompress(tail, index + 1, id, empty + hd, shot ++ acc)
    end
  end

  def inspect_decompressed(data) do
    lst = Tuple.to_list(data)

    Enum.map(lst, fn x -> "#{x}" end)
    |> List.to_string()
  end

  def find_first_empty_place(data, size) do
    Enum.reduce_while(0..(size - 1), :error, fn i, _acc ->
      if elem(data, i) == "." do
        {:halt, i}
      else
        {:cont, :error}
      end
    end)
  end

  def find_first_empty_place_that_fits(data, data_size, size) do
    Enum.reduce_while(0..(data_size - 1), {:error, 0, 0}, fn i, {_, empty_space, first_idx} ->
      cond do
        empty_space == size ->
          {:halt, {:ok, first_idx}}

        elem(data, i) == "." and empty_space == 0 ->
          {:cont, {:ok, empty_space + 1, i}}

        elem(data, i) == "." ->
          {:cont, {:ok, empty_space + 1, first_idx}}

        true ->
          {:cont, {:error, 0, 0}}
      end
    end)
  end

  def optimize_space(%{data: data, size: size, empty: empty}) do
    optimize_space(data, size, empty, 0)
  end

  def optimize_space(current_data, size, 0, _index), do: %{data: current_data, size: size}

  def optimize_space(current_data, size, empty, index) do
    to_move =
      elem(current_data, size - 1 - index)

    where_to_move = find_first_empty_place(current_data, size)

    new_data =
      put_elem(current_data, where_to_move, to_move)
      |> put_elem(size - 1 - index, ".")

    optimize_space(new_data, size, empty - 1, index + 1)
  end

  def calculate_checksum(%{data: data, size: size}) do
    Enum.reduce_while(0..(size - 1), 0, fn i, acc ->
      x = elem(data, i)

      case x do
        "." -> {:cont, acc}
        _ -> {:cont, acc + x * i}
      end
    end)
  end

  def optimize_space_part2(%{data: data, size: size, last_id: id}) do
    optimize_space_part2(data, size, id)
  end

  def optimize_space_part2(current_data, size, 0), do: %{data: current_data, size: size}

  def optimize_space_part2(current_data, size, current_id) do
    {file_size, file_idx} =
      file_size_and_idx_for_id(current_data, size, current_id)

    case find_first_empty_place_that_fits(current_data, size, file_size) do
      {:ok, i} when i < file_idx ->
        new_data = move_file(current_data, size, current_id, file_size, i)
        optimize_space_part2(new_data, size, current_id - 1)

      _ ->
        optimize_space_part2(current_data, size, current_id - 1)
    end
  end

  def file_size_and_idx_for_id(data, size, id) do
    Enum.reduce_while(0..(size - 1), {0, nil}, fn i, {acc, idx} ->
      if elem(data, i) == id do
        if idx == nil do
          {:cont, {acc + 1, i}}
        else
          {:cont, {acc + 1, idx}}
        end
      else
        {:cont, {acc, idx}}
      end
    end)
  end

  def move_file(data, data_size, id, size, dest) do
    new_data =
      Enum.reduce(0..(data_size - 1), data, fn i, acc ->
        if elem(acc, i) == id do
          put_elem(acc, i, ".")
        else
          acc
        end
      end)

    Enum.reduce(dest..(dest + size - 1), new_data, fn i, acc ->
      put_elem(acc, i, id)
    end)
  end

  def run1(use_puzzle \\ false) do
    get_input(use_puzzle)
    |> parse()
    |> IO.inspect(label: "Parsed")
    |> decompress()
    |> IO.inspect(label: "Decompressed")
    |> optimize_space()
    |> calculate_checksum()
  end

  def run2(use_puzzle \\ false) do
    get_input(use_puzzle)
    |> parse()
    |> decompress()
    |> IO.inspect(label: "Decompressed")
    |> optimize_space_part2()
    |> IO.inspect(label: "Optimised")
    |> calculate_checksum()
  end

  def temp do
    a =
      {0, 0, ".", ".", ".", 9, 9}

    file_size_and_idx_for_id(a, tuple_size(a), 9)
  end
end
