defmodule FlyioPriceCalc.Reservation do
  import FlyioPriceCalc.Group, only: [to_integer: 1]

  defstruct [
    :number,
    :region,
    :cpu_type,
    :plan
  ]

  def from_map(map) do
    Enum.reduce(map, %FlyioPriceCalc.Reservation{}, fn {key, value}, acc ->
      case key do
        "region" -> %{acc | region: value}
        "number" -> %{acc | number: to_integer(value)}
        "hours" -> %{acc | hours: to_integer(value)}
        "cpu_type" -> %{acc | cpu_type: value}
        "plan" -> %{acc | plan: to_integer(value)}
        _ -> acc
      end
    end)
  end

  def get_sizes() do
    ["shared", "performance"]
  end

  def get_text(cpu_type, plan) do
    case cpu_type do
      "performance" ->
        case plan do
          1 -> "$144/year for $20/month of usage"
          2 -> "$1,400/year for $200/month of usage"
          3 -> "$14,000/year for $2,000/month of usage"
        end
      _ ->
        case plan do
          1 -> "36/year for $5/month of usage"
          2 -> "$360/year for $50/month of usage"
          3 -> "$3,600/year for $500/month of usage"
        end
    end
  end

  def get_upfront(cpu_type, plan) do
    case cpu_type do
      "performance" ->
        case plan do
          1 -> 144
          2 -> 1400
          3 -> 14000
        end
      _ ->
        case plan do
          1 -> 36
          2 -> 360
          3 -> 3600
        end
    end
  end

  def get_monthly(cpu_type, plan) do
    case cpu_type do
      "performance" ->
        case plan do
          1 -> 20
          2 -> 200
          3 -> 2000
        end
      _ ->
        case plan do
          1 -> 5
          2 -> 50
          3 -> 500
        end
    end
  end
end
