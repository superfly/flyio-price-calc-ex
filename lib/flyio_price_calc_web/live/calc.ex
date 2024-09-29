defmodule FlyioPriceCalcWeb.Calc do
  use FlyioPriceCalcWeb, :live_view

  alias FlyioPriceCalc.Group

  def mount(_params, session, socket) do
    regions = FlyioPriceCalc.Regions.list_regions()

    region = case session |> Enum.into(%{}) do
      %{"fly-request-id" => request_id} when is_binary(request_id) ->
        region = request_id |> String.split("-") |> List.last

        if region in regions do
          region
        else
          "iad"
        end

      _ -> "iad"
    end

    {:ok, assign(socket,
      region: region,
      groups: [%Group{region: region, number: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 0}],
      regions: regions,
      cpu_types: ["shared", "dedicated"],
      bandwidth: %{region => 0}
    ) |> price}
  end

  def price(socket) do
    socket
    |> assign(price: FlyioPriceCalc.Price.calculate_price(socket.assigns))
  end

  def handle_event("add-machine", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: socket.assigns.region, number: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 0}]
    end) |> price}
  end

  def handle_event("add-pg-dev", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: socket.assigns.region, number: 1, cpu_type: "shared", cpu_count: 1, ram: 256, vol_size: 1}]
    end) |> price}
  end

  def handle_event("add-pg-prod-small", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: socket.assigns.region, number: 3, cpu_type: "shared", cpu_count: 2, ram: 4096, vol_size: 40}]
    end) |> price}
  end

  def handle_event("add-pg-prod-large", _, socket) do
    {:noreply, update(socket, :groups, fn groups ->
        groups ++ [%Group{region: socket.assigns.region, number: 3, cpu_type: "shared", cpu_count: 4, ram: 8192, vol_size: 80}]
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
    |> Enum.filter(fn {key, _value} -> key |> String.contains?("-") end)
    |> Enum.map(fn {key, value} -> {String.split(key, "-") |> List.last(), String.to_integer(value)} end)
    |> Enum.into(%{})

    {:noreply, assign(socket, bandwidth: bandwidth) |> price}
  end
end
