defmodule SQLiDetectWeb.Hooks.SQLiProtect do
  @moduledoc """
  A LiveView hook to prevent against SQLi via handle event payloads
  """

  alias SQLiDetect.Security.SQLi

  def on_mount(:default, _params, _session, socket) do
    socket =
      Phoenix.LiveView.attach_hook(socket, :sqli_protect, :handle_event, fn _event_name,
                                                                            params,
                                                                            socket ->
        if params_have_sqli?(params) do
          socket = Phoenix.Component.assign(socket, :sql?, true)

          {:cont, socket}
        else
          socket = Phoenix.Component.assign(socket, :sql?, false)
          {:cont, socket}
        end
      end)

    {:cont, socket}
  end

  defp params_have_sqli?(user_params) do
    keys = Map.keys(user_params)

    Enum.reduce(keys, false, fn
      "_target", sqli? ->
        sqli?

      "_unused_" <> _, sqli? ->
        sqli?

      key, _sqli? ->
        value = Map.get(user_params, key)
        SQLi.contains_sql_injection?(value)
    end)
  end
end
