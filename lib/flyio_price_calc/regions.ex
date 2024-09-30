defmodule FlyioPriceCalc.Regions do
  @moduledoc """
  This module provides functionalities to handle regions for Fly.io price calculations.
  """

  @default "iad"

  @regions ([
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
  ])

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
end
