defmodule PixelArtWeb.CanvasLive do
  use Phoenix.LiveView
  alias PixelArt.Canvas

  defp get_canvas_pid(topic) do
    name = {:via, Registry, {PixelArt.CanvasRegistry, topic}}

    case Agent.start_link(&Canvas.new/0, name: name) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def mount(%{path_params: %{"topic" => topic}}, socket) do
    {:ok, canvas_pid} = get_canvas_pid(topic)
    canvas = Agent.get(canvas_pid, &Canvas.list/1)

    if connected?(socket), do: PixelArtWeb.Endpoint.subscribe("canvas:" <> topic)

    {:ok,
     assign(socket, %{
       topic: topic,
       canvas_pid: canvas_pid,
       canvas: canvas,
       current_color: "#000000"
     })}
  end

  def render(assigns) do
    ~L"""
    <h1><%= @topic %></h1>
    <form phx-change="change">
      <input name="color" type="color" value="<%= @current_color %>" />
    </form>
    <svg width="1000" height="750" style="--current-color:<%= @current_color %>;">
    <%= for x <- 0..99, y <- 0..74 do %>
      <rect class="pixel" phx-click="click" phx-value="<%= "#{x},#{y}" %>" width="10" height="10" x="<%= x * 10 %>" y="<%= y * 10 %>" style="--pixel-color:<%= Canvas.get(@canvas,{x,y}) %>;" />
    <% end %>
    </svg>
    """
  end

  def handle_event("click", coordinates, socket) do
    [x, y] = coordinates |> String.split(",") |> Enum.map(&String.to_integer/1)

    Agent.update(socket.assigns.canvas_pid, &Canvas.put(&1, {x, y}, socket.assigns.current_color))
    PixelArtWeb.Endpoint.broadcast("canvas:" <> socket.assigns.topic, "updated", %{})

    {:noreply, socket}
  end

  def handle_event("change", %{"color" => color}, socket) do
    {:noreply, assign(socket, :current_color, color)}
  end

  def handle_info(
        %{topic: "canvas:" <> topic, event: "updated"},
        %{assigns: %{topic: topic}} = socket
      ) do
    canvas = Agent.get(socket.assigns.canvas_pid, &Canvas.list/1)
    {:noreply, assign(socket, :canvas, canvas)}
  end
end
