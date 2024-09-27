defmodule FlyioPriceCalc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FlyioPriceCalcWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:flyio_price_calc, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FlyioPriceCalc.PubSub},
      # Start a worker by calling: FlyioPriceCalc.Worker.start_link(arg)
      # {FlyioPriceCalc.Worker, arg},
      # Start to serve requests, typically the last entry
      FlyioPriceCalcWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlyioPriceCalc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlyioPriceCalcWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
