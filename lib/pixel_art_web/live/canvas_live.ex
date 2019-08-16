defmodule PixelArtWeb.CanvasLive do
  use Phoenix.LiveView
  alias PixelArt.Canvas

  defp get_canvas(topic) do
    name = {:via, Registry, {PixelArt.CanvasRegistry, topic}}

    case Agent.start_link(&Canvas.new/0, name: name) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def mount(%{path_params: %{"topic" => topic}}, socket) do
    {:ok, canvas} = get_canvas(topic)
    {:ok, assign(socket, %{topic: topic, canvas: canvas})}
  end

  def render(assigns) do
    ~L"""
    <pre>
    <%= inspect assigns %>
    </pre>
    """
  end
end
