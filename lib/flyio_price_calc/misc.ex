defmodule FlyioPriceCalc.Misc do
  import FlyioPriceCalc.Group, only: [to_integer: 1]

  defstruct [
    :ipv4,
    :ssl_hostname,
    :ssl_wildcard,
    :static_ip,
    :fks
  ]

  def from_map(map) do
    Enum.reduce(map, %FlyioPriceCalc.Misc{}, fn {key, value}, acc ->
      case key do
        "ipv4" -> %{acc | ipv4: to_integer(value)}
        "ssl_hostname" -> %{acc | ssl_hostname: to_integer(value)}
        "ssl_wildcard" -> %{acc | ssl_wildcard: to_integer(value)}
        "static_ip" -> %{acc | static_ip: to_integer(value)}
        "fks" -> %{acc | fks: to_integer(value)}
        _ -> acc
      end
    end)
  end
end
