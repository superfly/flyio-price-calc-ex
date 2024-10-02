defmodule FlyioPriceCalc.Price do
  alias FlyioPriceCalc.Regions

  def calculate_price(assigns) do
    price = %{}

    # shared: $0.695 per 1 vCPU per month
    # performance: $21 per 1 vCPU per month
    compute =
      Enum.reduce(assigns.groups, 0, fn group, acc ->
        case group.cpu_type do
          "performance" ->
            acc +
              group.number * group.hours / 720 * group.cpu_count * 21 *
                Regions.get_markup(group.region)

          "A10" ->
            acc + group.number * group.hours * group.cpu_count * 1.50

          "L40S" ->
            acc + group.number * group.hours * group.cpu_count * 1.25

          "A100 40G PCIe" ->
            acc + group.number * group.hours * group.cpu_count * 2.50

          "A100 80G SXM" ->
            acc + group.number * group.hours * group.cpu_count * 3.50

          _ ->
            acc +
              group.number * group.hours / 720 * group.cpu_count * 0.695 *
                Regions.get_markup(group.region)
        end
      end)

    price =
      case compute do
        +0.0 -> price
        -0.0 -> price
        _ -> Map.put(price, :compute, compute)
      end

    # -------------------

    # $5 per 1GB of RAM
    memory =
      Enum.reduce(assigns.groups, 0, fn group, acc ->
        acc + group.number * group.ram / 1024 * 5
      end)

    price =
      case memory do
        +0.0 -> price
        -0.0 -> price
        _ -> Map.put(price, :memory, memory)
      end

    # -------------------

    # $0.15/GB per month
    volume =
      Enum.reduce(assigns.groups, 0, fn group, acc ->
        acc + group.number * group.vol_size * 0.15
      end)

    price =
      case volume do
        +0.0 -> price
        -0.0 -> price
        _ -> Map.put(price, :volume, volume)
      end

    # -------------------

    # North America, Europe: $0.02 per GB per month
    # Asia Pacific, Oceania, South America: $0.04 per GB per month
    # Africa, India: $0.12 per GB per month
    bandwidth =
      Enum.reduce(assigns.bandwidth, 0, fn {region, value}, acc ->
        acc +
          case Regions.get_group(region) do
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

    price =
      case bandwidth do
        +0.0 -> price
        -0.0 -> price
        _ -> Map.put(price, :bandwidth, bandwidth)
      end

    # -------------------

    # Support
    price =
      case assigns.addons.support do
        "none" -> price
        "standard" -> Map.put(price, :support, 29)
        "premium" -> Map.put(price, :support, 199)
        "enterprise" -> Map.put(price, :support, 2500)
        _ -> price
      end

    # -------------------

    # Compliance
    price =
      case assigns.addons.compliance do
        "no" -> price
        "yes" -> Map.put(price, :compliance, 99)
        _ -> price
      end

    price
  end
end
