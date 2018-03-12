use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :plum, PlumWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [npm: ["--prefix", "./assets", "start"]]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# command from your terminal:
#
#     openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout priv/server.key -out priv/server.pem
#
# The `http:` config above can be replaced with:
#
#     https: [port: 4000, keyfile: "priv/server.key", certfile: "priv/server.pem"],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :plum, PlumWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg|scss)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/plum_web/views/.*(ex)$},
      ~r{lib/plum_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :plum, Plum.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "plum_dev",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool_size: 10,
  types: Plum.PostgresTypes

config :plum, PlumWeb.Mailer,
  adapter: Swoosh.Adapters.Local

# config :plum, PlumWeb.Mailer,
  # adapter: Swoosh.Adapters.SMTP,
  # relay: "email-smtp.eu-west-1.amazonaws.com",
  # port: 465,
  # username: System.get_env("SMTP_USERNAME"),
  # password: System.get_env("SMTP_PASSWORD"),
  # tls: :if_available,
  # ssl: true,
  # auth: :always,
  # retries: 3

config :plum,
  mixpanel_token: "570aa0ff2af04cf1609e778c6a5eda10",
  aircall_webhook_token: System.get_env("AIRCALL_WEBHOOK_TOKEN"),
  aircall_api_id: System.get_env("AIRCALL_API_ID"),
  aircall_api_token: System.get_env("AIRCALL_API_TOKEN")

config :plum,
  env: "dev",
  dodo_url: "localhost:4200",
  geocoding_api_key: System.get_env("GEOCODING_API_KEY")

config :plum,
  land_ads_sqs_queue: System.get_env("LAND_ADS_SQS_QUEUE"),
  land_ads_s3_bucket: System.get_env("LAND_ADS_S3_BUCKET")

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: "eu-west-1",
  s3: [
    scheme: "https://",
    host: "s3-eu-west-1.amazonaws.com",
    region: "eu-west-1"
  ]
