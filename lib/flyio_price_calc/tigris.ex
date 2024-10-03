defmodule FlyioPriceCalc.Tigris do
  import FlyioPriceCalc.Group, only: [to_integer: 1]

  defstruct [
    :data_storage,
    :class_a,
    :class_b
  ]

  def from_map(map) do
    Enum.reduce(map, %FlyioPriceCalc.Tigris{}, fn {key, value}, acc ->
      case key do
        "data_storage" -> %{acc | data_storage: to_integer(value)}
        "class_a" -> %{acc | class_a: to_integer(value)}
        "class_b" -> %{acc | class_b: to_integer(value)}
        _ -> acc
      end
    end)
  end
end
