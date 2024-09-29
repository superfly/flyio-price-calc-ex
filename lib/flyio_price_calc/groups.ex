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
        "number" -> %{acc | number: String.to_integer(value)}
        "cpu_type" -> %{acc | cpu_type: value}
        "cpu_count" -> %{acc | cpu_count: String.to_integer(value)}
        "ram" -> %{acc | ram: String.to_integer(value)}
        "vol_size" -> %{acc | vol_size: String.to_integer(value)}
        _ -> acc
      end
    end)
  end
end
