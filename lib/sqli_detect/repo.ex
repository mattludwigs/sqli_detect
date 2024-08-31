defmodule SQLiDetect.Repo do
  use Ecto.Repo,
    otp_app: :sqli_detect,
    adapter: Ecto.Adapters.SQLite3
end
