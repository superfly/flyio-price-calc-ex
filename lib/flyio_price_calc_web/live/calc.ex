defmodule FlyioPriceCalcWeb.Calc do
  use FlyioPriceCalcWeb, :live_view

  alias FlyioPriceCalc.Group
  alias FlyioPriceCalc.Misc
  alias FlyioPriceCalc.Regions
  alias FlyioPriceCalc.Reservation
  alias FlyioPriceCalc.Tigris
  alias FlyioPriceCalc.Upstash

  alias Number.Currency

  def mount(_params, session, socket) do
    region = case session |> Enum.into(%{}) do
      %{"fly-request-id" => request_id} when is_binary(request_id) ->
        Regions.get_region(request_id |> String.split("-") |> List.last)
      _ -> Regions.get_default()
    end

    {:ok, assign(socket,
      region: region,
      groups: [%Group{region: region, number: 1, cpu_type: "shared", cpu_count: 1, hours: 730, ram: 256, vol_size: 0}],
      regions: Regions.list_regions(),
      cpu_types: ["shared", "performance", "A10", "L40S", "A100 40G PCIe", "A100 80G SXM"],
      bandwidth: %{region => 0},
      addons: %{compliance: "no", support: "none"},
      support_types: ["none", "standard", "premium", "enterprise"],
      reservations: [%Reservation{region: region, number: 0, cpu_type: "shared", plan: 1}],
      reservation_cpu_types: Reservation.get_sizes(),
      tigris: %Tigris{data_storage: 5, class_a: 10, class_b: 100},
      upstash: %Upstash{plan: 0, requests: 100, regions: 1},
      misc: %Misc{ipv4: 0, ssl_hostname: 0, ssl_wildcard: 0, static_ip: 0, fks: 0}
    ) |> price}
  end

  def price(socket) do
    {price, upfront} = FlyioPriceCalc.Price.calculate_price(socket.assigns)

    socket
    |> assign(price: price, upfront: upfront)
  end

  def handle_event("add-machine", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: socket.assigns.region, number: 1, cpu_type: "shared", cpu_count: 1, hours: 730, ram: 256, vol_size: 0}]
    end) |> price}
  end

  def handle_event("add-pg-dev", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: socket.assigns.region, number: 1, cpu_type: "shared", cpu_count: 1, hours: 730, ram: 256, vol_size: 1}]
    end) |> price}
  end

  def handle_event("add-pg-prod-small", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: socket.assigns.region, number: 3, cpu_type: "shared", cpu_count: 2, hours: 730, ram: 4096, vol_size: 40}]
    end) |> price}
  end

  def handle_event("add-pg-prod-large", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: socket.assigns.region, number: 3, cpu_type: "shared", cpu_count: 4, hours: 730, ram: 8192, vol_size: 80}]
    end) |> price}
  end

  def handle_event("change-groups", formdata, socket) do
    groups = formdata
    |> Enum.filter(fn {key, _value} -> key |> String.contains?("-") end)
    |> Enum.group_by(fn {key, _value} -> String.split(key, "-") |> List.last() end)
    |> Enum.map(fn {_row, pairs} -> pairs |> Map.new(fn {key, value} ->
      {String.split(key, "-") |> List.first, value} end) |> Group.from_map()
    end)

    bandwidth = groups
    |> Enum.map(fn group -> {group.region, 0} end) |> Enum.into(%{})
    |> Map.merge(socket.assigns.bandwidth)

    {:noreply, assign(socket, groups: groups, bandwidth: bandwidth) |> price}
  end

  def handle_event("change-bandwidth", formdata, socket) do
    bandwidth = formdata
    |> Enum.filter(fn {key, _value} -> key |> String.starts_with?("region-") end)
    |> Enum.map(fn {key, value} -> {String.split(key, "-") |> List.last(), Group.to_integer(value)} end)
    |> Enum.into(%{})

    {:noreply, assign(socket, bandwidth: bandwidth) |> price}
  end

  def handle_event("change-extensions", formdata, socket) do
    tigris = formdata
    |> Enum.filter(fn {key, _value} -> key |> String.contains?("tigris-") end)
    |> Enum.map(fn {key, value} -> {String.split(key, "-") |> List.last, value} end)
    |> Tigris.from_map

    upstash = formdata
    |> Enum.filter(fn {key, _value} -> key |> String.contains?("upstash-") end)
    |> Enum.map(fn {key, value} -> {String.split(key, "-") |> List.last, value} end)
    |> Upstash.from_map(socket.assigns.upstash)

    {:noreply, assign(socket, tigris: tigris, upstash: upstash) |> price}
  end

  def handle_event("change-addons", formdata, socket) do
    addons = %{
      compliance: Map.get(formdata, "compliance", "no"),
      support: Map.get(formdata, "support", "none")
    }

    {:noreply, assign(socket, addons: addons) |> price}
  end

  def handle_event("change-reservations", formdata, socket) do
    reservations = formdata
    |> Enum.filter(fn {key, _value} -> key |> String.contains?("-") end)
    |> Enum.group_by(fn {key, _value} -> String.split(key, "-") |> List.last() end)
    |> Enum.map(fn {_row, pairs} -> pairs |> Map.new(fn {key, value} ->
      {String.split(key, "-") |> List.first, value} end) |> Reservation.from_map()
    end)

    {:noreply, assign(socket, reservations: reservations) |> price}
  end

  def handle_event("add-reservation", _, socket) do
    {:noreply, update(socket, :reservations, fn reservations ->
        reservations ++ [%Reservation{region: socket.assigns.region, number: 0, cpu_type: "shared", plan: 1}]
    end) |> price}
  end

  def handle_event("change-misc", formdata, socket) do
    misc = formdata
    |> Enum.filter(fn {key, _value} -> key |> String.contains?("misc-") end)
    |> Enum.map(fn {key, value} -> {String.split(key, "-") |> List.last, value} end)
    |> Misc.from_map

    {:noreply, assign(socket, misc: misc) |> price}
  end
end
