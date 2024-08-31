defmodule SQLiDetectWeb.OverviewLive do
  use SQLiDetectWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:logs, [])
      |> assign_form()

    {:ok, socket}
  end

  def handle_event("save", %{"input" => input}, socket) do
    socket =
      socket
      |> update(:logs, fn log -> log ++ [input] end)
      |> assign_form()

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>SQLi Detection for Websocket Payloads</h1>

    <.simple_form for={@form} phx-submit="save">
      <.input field={@form[:input]} label="Email" />
      <:actions>
        <.button>Submit</.button>
      </:actions>
    </.simple_form>

    <ul class="mt-8 spacing-y-4">
      <li :for={log <- @logs}>
        <%= log %>
      </li>
    </ul>
    """
  end

  def assign_form(socket) do
    assign(socket, :form, to_form(%{"input" => ""}))
  end
end
