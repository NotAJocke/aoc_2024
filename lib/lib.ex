defmodule Matrix do
  defstruct data: nil, size: {0, 0}

  def parse(string, :string) do
    data =
      String.split(string, "\n", trim: true)
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    %Matrix{
      data: data,
      size: {tuple_size(elem(data, 0)), tuple_size(data)}
    }
  end

  def parse(string, :int) do
    data =
      String.split(string, "\n", trim: true)
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(fn line ->
        Enum.map(line, &String.to_integer/1)
      end)
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    %Matrix{
      data: data,
      size: {tuple_size(elem(data, 0)), tuple_size(data)}
    }
  end

  def get_at(matrix, x, y) do
    elem(elem(matrix.data, y), x)
  end

  def in_bounds?(matrix, x, y) do
    if x < 0 or x >= elem(matrix.size, 0) or y < 0 or y >= elem(matrix.size, 1) do
      false
    else
      true
    end
  end
end
