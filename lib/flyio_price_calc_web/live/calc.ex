defmodule FlyioPriceCalcWeb.Calc do
  use FlyioPriceCalcWeb, :live_view

  alias FlyioPriceCalc.Group

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      groups: [%Group{region: "iad", count: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 0}],
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
        groups ++ [%Group{region: "iad", count: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 0}]
    end)}
  end

  def handle_event("add-pg-dev", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: "iad", count: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 1}]
    end)}
  end

  def handle_event("add-pg-prod-small", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: "iad", count: 3, cpu_type: "shared", cpu_count: 2, ram: 4096, vol_size: 40}]
    end)}
  end

  def handle_event("add-pg-prod-large", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: "iad", count: 3, cpu_type: "shared", cpu_count: 4, ram: 8192, vol_size: 80}]
    end)}
  end
end
