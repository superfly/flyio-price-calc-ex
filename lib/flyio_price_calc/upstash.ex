defmodule FlyioPriceCalc.Upstash do
  import FlyioPriceCalc.Group, only: [to_integer: 1]

  defstruct [
    :plan,
    :requests,
    :regions
  ]

  def from_map(map, base) do
    Enum.reduce(map, base, fn {key, value}, acc ->
      case key do
        "plan" -> %{acc | plan: to_integer(value)}
        "requests" -> %{acc | requests: to_integer(value)}
        "regions" -> %{acc | regions: to_integer(value)}
        _ -> acc
      end
    end)
  end

  def get_text(plan) do
    case plan do
      0 -> "None"
      1 -> "Pay as you go: $0.20 per 100K requests"
      2 -> "Starter: $10 per month, single region only. Includes 200MB storage, 100 req/sec"
      3 -> "Standard: $50 per month, per region. Includes 3GB storage, 100 req/sec"
      4 -> "Pro 2K: $280 per month, $100 per replica region. Includes 50GB storage, 10k req/sec"
    end
  end

  def get_per_month(upstash) do
    case upstash.plan do
      0 -> 0
      1 -> 0.20 * upstash.requests / 100
      2 -> 10
      3 -> 50 * upstash.regions
      4 -> 280 + upstash.regions * 100
    end
  end
end
