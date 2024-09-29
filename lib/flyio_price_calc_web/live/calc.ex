defmodule FlyioPriceCalcWeb.Calc do
  use FlyioPriceCalcWeb, :live_view

  alias FlyioPriceCalc.Group

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      groups: [%Group{region: "iad", number: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 0}],
      regions: FlyioPriceCalc.Regions.list_regions(),
      cpu_types: ["shared", "dedicated"],
      bandwidth: %{"iad" => 0}
    ) |> price}
  end

  def price(socket) do
    socket
    |> assign(price: FlyioPriceCalc.Price.calculate_price(socket.assigns))
  end

  def handle_event("add-machine", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: "iad", number: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 0}]
    end) |> price}
  end

  def handle_event("add-pg-dev", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: "iad", number: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 1}]
    end) |> price}
  end

  def handle_event("add-pg-prod-small", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: "iad", number: 3, cpu_type: "shared", cpu_count: 2, ram: 4096, vol_size: 40}]
    end) |> price}
  end

  def handle_event("add-pg-prod-large", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: "iad", number: 3, cpu_type: "shared", cpu_count: 4, ram: 8192, vol_size: 80}]
    end) |> price}
  end

  def handle_event("change-groups", formdata, socket) do
    groups = (formdata
    |> Enum.filter(fn {key, _value} -> key |> String.contains?("-") end)
    |> Enum.group_by(fn {key, _value} -> String.split(key, "-") |> List.last() end)
    |> Enum.map(fn {_row, pairs} -> pairs |> Map.new(fn {key, value} ->
      {String.split(key, "-") |> List.first, value} end) |> Group.from_map()
    end))

    {:noreply, assign(socket, groups: groups) |> price}
  end
end
