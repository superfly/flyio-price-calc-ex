defmodule FlyioPriceCalc.Price do
  def calculate_price(%{groups: groups, bandwidth: bandwidth}) do
    %{
      cpu: Enum.reduce(groups, 0, fn group, acc -> acc + group.number * group.cpu_count end),
      memory: Enum.reduce(groups, 0, fn group, acc -> acc + group.number * group.ram end),
      volume: Enum.reduce(groups, 0, fn group, acc -> acc + group.number * group.vol_size end),
      bandwidth: Enum.reduce(bandwidth, 0, fn {_, value}, acc -> acc + value end)
    }
  end
end
