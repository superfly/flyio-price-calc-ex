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
end
