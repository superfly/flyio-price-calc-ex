defmodule FlyioPriceCalc.Price do
  alias FlyioPriceCalc.Regions

  def calculate_price(%{groups: groups, bandwidth: bandwidth}) do
    # shared: $0.695 per 1 vCPU per month
    # performance: $21 per 1 vCPU per month
    compute = Enum.reduce(groups, 0, fn group, acc ->
      if group.cpu_type == "performance" do
        acc + group.number * group.cpu_count * 21
      else
        acc + group.number * group.cpu_count * 0.695
      end
    end)

    # $5 per 1GB of RAM
    memory = Enum.reduce(groups, 0, fn group, acc ->
      acc + group.number * group.ram/1024 * 5
    end)

    # $0.15/GB per month
    volume = Enum.reduce(groups, 0, fn group, acc ->
      acc + group.number * group.vol_size * 0.15
    end)

    # North America, Europe: $0.02 per GB per month
    # Asia Pacific, Oceania, South America: $0.04 per GB per month
    # Africa, India: $0.12 per GB per month
    bandwidth = Enum.reduce(bandwidth, 0, fn {region, value}, acc ->
      acc + case Regions.get_group(region) do
        :na -> value * 0.02
        :eu -> value * 0.02

        :ap -> value * 0.04
        :oc -> value * 0.04
        :sa -> value * 0.04

        :af -> value * 0.12
        :in -> value * 0.12

        _ -> value * 0.02
      end
    end)

    %{
      compute: compute,
      memory: memory,
      volume: volume,
      bandwidth: bandwidth,
    }
  end
end
