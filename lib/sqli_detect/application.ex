defmodule SQLiDetect.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SQLiDetectWeb.Telemetry,
      SQLiDetect.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:sqli_detect, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:sqli_detect, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SQLiDetect.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SQLiDetect.Finch},
      # Start a worker by calling: SQLiDetect.Worker.start_link(arg)
      # {SQLiDetect.Worker, arg},
      # Start to serve requests, typically the last entry
      SQLiDetectWeb.Endpoint,
      SQLiDetect.Security.SQLi
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SQLiDetect.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SQLiDetectWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
