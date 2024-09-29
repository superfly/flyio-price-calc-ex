defmodule FlyioPriceCalcWeb.Plugs.FlyRequest do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _default) do
    fly_request = conn |> get_req_header("fly-request-id") |> List.first

    conn
    |> put_session("fly-request-id", fly_request)
  end
end
