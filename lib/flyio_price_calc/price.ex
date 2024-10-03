defmodule FlyioPriceCalc.Price do
  alias FlyioPriceCalc.Regions
  alias FlyioPriceCalc.Reservation
  alias FlyioPriceCalc.Upstash

  def calculate_price(assigns) do
    price = %{}

    # shared: $0.695 per 1 vCPU per month
    # performance: $21 per 1 vCPU per month
    compute_by_region_and_type =
      Enum.map(assigns.groups, fn group ->
        {group.region, group.cpu_type,
         case group.cpu_type do
           "performance" ->
             group.number * group.hours / 720 * group.cpu_count * 21 *
               Regions.get_markup(group.region)

           "A10" ->
             group.number * group.hours * group.cpu_count * 1.50

           "L40S" ->
             group.number * group.hours * group.cpu_count * 1.25

           "A100 40G PCIe" ->
             group.number * group.hours * group.cpu_count * 2.50

           "A100 80G SXM" ->
             group.number * group.hours * group.cpu_count * 3.50

           _ ->
             group.number * group.hours / 720 * group.cpu_count * 0.695 *
               Regions.get_markup(group.region)
         end}
      end)
      |> Enum.group_by(fn {region, type, _} -> {region, type} end)
      |> Enum.map(fn {key, values} ->
        {key, Enum.reduce(values, 0, fn {_, _, value}, acc -> acc + value end)}
      end)

    # -------------------

    # $5 per 1GB of RAM
    memory_by_region_and_type =
      Enum.map(assigns.groups, fn group ->
        {group.region, group.cpu_type, group.number * group.ram / 1024 * 5}
      end)
      |> Enum.group_by(fn {region, type, _} -> {region, type} end)
      |> Enum.map(fn {key, values} ->
        {key, Enum.reduce(values, 0, fn {_, _, value}, acc -> acc + value end)}
      end)

    # -------------------

    # tagged compute
    tagged_compute =
      compute_by_region_and_type
      |> Enum.map(fn {key, value} -> {key, %{compute: value}} end)
      |> Enum.into(%{})

    # tagged memory
    tagged_memory =
      memory_by_region_and_type
      |> Enum.map(fn {key, value} -> {key, %{memory: value}} end)
      |> Enum.into(%{})

    # merge tagged compute and memory
    combined =
      Map.merge(tagged_compute, tagged_memory, fn _key, compute, memory ->
        Map.merge(compute, memory)
      end)

    # apply reservations
    {compute_by_region_and_type, memory_by_region_and_type} =
      combined
      |> Enum.map(fn {key, values} ->
        compute = values |> Map.get(:compute, 0)
        memory = values |> Map.get(:memory, 0)

        {region, type} = key

        reservation =
          assigns.reservations
          |> Enum.filter(fn reservation ->
            reservation.region == region and reservation.cpu_type == type
          end)
          |> Enum.reduce(0, fn reservation, acc ->
            acc + Reservation.get_monthly(reservation.cpu_type, reservation.plan) * reservation.number
          end)

        cond do
          reservation == 0 ->
            {key, compute, memory}

          reservation > compute + memory ->
            {key, 0, 0}

          reservation > compute ->
            {key, 0, compute + memory - reservation}

          true ->
            {key, compute - reservation, memory}
        end
      end)
      |> Enum.reduce({[], []}, fn {key, compute, memory}, {compute_acc, memory_acc} ->
        {[{key, compute} | compute_acc], [{key, memory} | memory_acc]}
      end)

    # -------------------

    # apply compute and memory prices, after reservations
    compute =
      compute_by_region_and_type
      |> Enum.reduce(0, fn {_, value}, acc -> acc + value end)

    price =
      case compute do
        0.0 -> price
        _ -> Map.put(price, :compute, compute)
      end

    memory =
      memory_by_region_and_type
      |> Enum.reduce(0, fn {_, value}, acc -> acc + value end)

    price =
      case memory do
        0.0 -> price
        _ -> Map.put(price, :memory, memory)
      end

    # -------------------

    tigris =
      max(0, (assigns.tigris.data_storage - 5) * 0.02) +
      max(0, (assigns.tigris.class_a - 10) * 0.005) +
      max(0, (assigns.tigris.class_b - 100) * 0.0005)

    price =
      case tigris do
        0 -> price
        _ -> Map.put(price, :tigris, tigris)
      end

    # -------------------

    upstash = Upstash.get_per_month(assigns.upstash)

    price =
      case upstash do
        0 -> price
        _ -> Map.put(price, :upstash, upstash)
      end

    # -------------------

    upfront = assigns.reservations
      |> Enum.reduce(0, fn reservation, acc ->
        acc + Reservation.get_upfront(reservation.cpu_type, reservation.plan) * reservation.number
      end)

    # -------------------

    # $0.15/GB per month
    volume =
      Enum.reduce(assigns.groups, 0, fn group, acc ->
        acc + group.number * group.vol_size * 0.15
      end)

    price =
      case volume do
        0.0 -> price
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
        0.0 -> price
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

    # -------------------

    misc = (
      assigns.misc.ipv4 * 2 +
      assigns.misc.ssl_hostname * 0.10 +
      assigns.misc.ssl_wildcard * 1 +
      assigns.misc.static_ip * 0.005 +
      assigns.misc.fks * 75
    )

    price =
      case misc do
        0.0 -> price
        _ -> Map.put(price, :misc, misc)
      end

    # -------------------

    {price, upfront}
  end
end
