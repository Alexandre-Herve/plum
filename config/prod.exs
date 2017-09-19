use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# PlumWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phx.digest task
# which you typically run after static files are built.
config :plum, PlumWeb.Endpoint,
  load_from_system_env: true,
  url: [
    scheme: "http",
    host: "${APP_URL}",
    port: 80
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :plum, PlumWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :plum, PlumWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :plum, PlumWeb.Endpoint, server: true
#

config :plum, PlumWeb.Endpoint,
  secret_key_base: "RLN4oJZRgNsGUAEuRErB0LYRwFE6hbq/AmObcpOc8WWQjZtU4H5HQVDtThZpa2+C"

config :plum, Plum.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "${RDS_USERNAME}",
  password: "${RDS_PASSWORD}",
  database: "${RDS_DB_NAME}",
  hostname: "${RDS_URL}",
  port: "${RDS_PORT}",
  pool_size: 15

config :coherence, PlumWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "email-smtp.eu-west-1.amazonaws.com",
  port: 465,
  username: "${SMTP_USERNAME}",
  password: "${SMTP_PASSWORD}",
  tls: :if_available,
  ssl: true,
  auth: :always,
  retries: 3

config :plum, PlumWeb.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "email-smtp.eu-west-1.amazonaws.com",
  port: 465,
  username: "${SMTP_USERNAME}",
  password: "${SMTP_PASSWORD}",
  tls: :if_available,
  ssl: true,
  auth: :always,
  retries: 3
