defmodule BanditFly do
  use Plug.Builder
  require Logger

  plug :fly_region

  plug Plug.Logger, log: :debug
  plug Plug.Telemetry, event_prefix: [:bandit_fly, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: JSON

  plug Plug.MethodOverride
  plug Plug.Head

  plug :hey

  defp fly_region(conn, _opts) do
    # https://fly.io/docs/networking/request-headers/#fly-region
    with [region] <- get_req_header(conn, "fly-region"),
         Logger.metadata(fly_region: region) do
      conn
    else
      _ -> conn
    end
  end

  def is_primary do
    System.get_env("FLY_REGION") == primary_region()
  end

  defp primary_region do
    System.get_env("PRIMARY_REGION")
  end

  defp fly_replay_on_primary(conn) do
    conn
    |> put_resp_header("fly-replay", "region=#{primary_region()}")
    |> send_resp(409, [])
    |> halt()
  end

  def call(conn, opts) do
    if is_primary() do
      super(conn, opts)
    else
      Logger.info("replaying request to primary region: #{primary_region()}")
      fly_replay_on_primary(conn)
    end
  end

  def hey(conn, _opts) do
    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(200, "Hey from Bandit, Fly!\n\n")
  end
end
