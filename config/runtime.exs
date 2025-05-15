import Config

config :logger, :console,
  metadata: [:remote_ip, :fly_region],
  format: "$time [$level] $metadata $message\n"
