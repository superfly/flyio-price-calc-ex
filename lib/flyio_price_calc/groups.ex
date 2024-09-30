defmodule FlyioPriceCalc.Group do
  defstruct [
    :region,
    :number,
    :cpu_type,
    :cpu_count,
    :ram,
    :vol_size,
  ]

  def from_map(map) do
    Enum.reduce(map, %FlyioPriceCalc.Group{}, fn {key, value}, acc ->
      case key do
        "region" -> %{acc | region: value}
        "number" -> %{acc | number: to_integer(value)}
        "cpu_type" -> %{acc | cpu_type: value}
        "cpu_count" -> %{acc | cpu_count: to_integer(value)}
        "ram" -> %{acc | ram: to_integer(value)}
        "vol_size" -> %{acc | vol_size: to_integer(value)}
        _ -> acc
      end
    end)
  end

  def to_integer(string) do
    case Integer.parse(string) do
      {value, _} -> value
      :error -> 0
    end
  end
end
