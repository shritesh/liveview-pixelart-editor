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
    {:ok, assign(socket, %{topic: topic, canvas_pid: canvas_pid, canvas: canvas})}
  end

  def render(assigns) do
    ~L"""
    <svg width="1000" height="750" style="--current-color:red;">
    <%= for x <- 0..99, y <- 0..74 do %>
      <% {r,g,b} = Canvas.get(@canvas,{x,y}) %>
      <rect class="pixel" phx-click="click" phx-value="<%= "#{x},#{y}" %>" width="10" height="10" x="<%= x * 10 %>" y="<%= y * 10 %>" style="--pixel-color:rgb(<%= "#{r},#{g},#{b}" %>)" />
    <% end %>
    </svg>
    """
  end

  def handle_event("click", coordinates, socket) do
    [x, y] = coordinates |> String.split(",") |> Enum.map(&String.to_integer/1)

    Agent.update(socket.assigns.canvas_pid, &Canvas.put(&1, {x, y}, {100, 0, 0}))
    canvas = Agent.get(socket.assigns.canvas_pid, &Canvas.list/1)
    {:noreply, assign(socket, :canvas, canvas)}
  end
end
