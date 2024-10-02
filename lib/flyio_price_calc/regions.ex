defmodule FlyioPriceCalc.Regions do
  @moduledoc """
  This module provides functionalities to handle regions for Fly.io price calculations.
  """

  @default "iad"

  @regions [
    "ams",
    "arn",
    "atl",
    "bog",
    "bom",
    "bos",
    "cdg",
    "den",
    "dfw",
    "ewr",
    "eze",
    "fra",
    "gdl",
    "gig",
    "gru",
    "hkg",
    "iad",
    "jnb",
    "lax",
    "lhr",
    "maa",
    "mad",
    "mia",
    "nrt",
    "ord",
    "otp",
    "phx",
    "qro",
    "scl",
    "sea",
    "sin",
    "sjc",
    "syd",
    "waw",
    "yul",
    "yyz"
  ]

  @groups %{
    "ams" => :eu,
    "arn" => :na,
    "atl" => :na,
    "bog" => :sa,
    "bom" => :in,
    "bos" => :na,
    "cdg" => :eu,
    "den" => :na,
    "dfw" => :na,
    "ewr" => :na,
    "eze" => :sa,
    "fra" => :eu,
    "gdl" => :na,
    "gig" => :sa,
    "gru" => :sa,
    "hkg" => :ap,
    "iad" => :na,
    "jnb" => :af,
    "lax" => :na,
    "lhr" => :eu,
    "maa" => :eu,
    "mad" => :eu,
    "mia" => :na,
    "nrt" => :ap,
    "ord" => :na,
    "otp" => :eu,
    "phx" => :na,
    "qro" => :na,
    "scl" => :sa,
    "sea" => :na,
    "sin" => :ap,
    "sjc" => :na,
    "syd" => :oc,
    "waw" => :eu,
    "yul" => :na,
    "yyz" => :na
  }

  @markups %{
    "iad" => 1,
    "ewr" => 1,
    "ams" => 1.038461538,
    "arn" => 1.038461538,
    "bom" => 1.076923077,
    "mad" => 1.096153846,
    "yul" => 1.115384615,
    "yyz" => 1.115384615,
    "lhr" => 1.134615385,
    "cdg" => 1.134615385,
    "fra" => 1.153846154,
    "sjc" => 1.192307692,
    "lax" => 1.199519231,
    "atl" => 1.25,
    "bos" => 1.25,
    "ord" => 1.25,
    "dfw" => 1.25,
    "den" => 1.25,
    "mia" => 1.25,
    "phx" => 1.25,
    "sea" => 1.25,
    "sin" => 1.269230769,
    "syd" => 1.269230769,
    "jnb" => 1.302884615,
    "nrt" => 1.307692308,
    "otp" => 1.326923077,
    "waw" => 1.326923077,
    "gdl" => 1.350961538,
    "qro" => 1.350961538,
    "hkg" => 1.403846154,
    "bog" => 1.615384615,
    "gig" => 1.615384615,
    "gru" => 1.615384615,
    "scl" => 1.697115385,
    "eze" => 1.858173077
  }

  @doc """
  Returns the list of available regions.
  """
  def list_regions do
    @regions
  end

  def get_default do
    @default
  end

  def get_region(edge) do
    case edge do
      _ when edge in @regions -> edge
      "chi" -> "ord"
      "nyc" -> "ewr"
      "mel" -> "syd"
      "ist" -> "waw"
      "dxb" -> "bom"
      _ -> @default
    end
  end

  def get_group(region) do
    Map.get(@groups, region, :na)
  end

  def get_markup(region) do
    Map.get(@markups, region, 1)
  end
end
