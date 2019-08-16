defmodule PixelArt.Canvas do
  @gridsize_x 100
  @gridsize_y 75
  @default_color "#ffffff"

  defguard is_in_bounds(x, y) when x >= 0 and x < @gridsize_x and y >= 0 and y < @gridsize_y

  def new(), do: %{}

  def get(canvas, {x, y}) when is_in_bounds(x, y) do
    case Map.get(canvas, {x, y}) do
      nil -> @default_color
      color -> color
    end
  end

  def put(canvas, {x, y} = coordinates, color)
      when is_in_bounds(x, y),
      do: Map.put(canvas, coordinates, color)

  def list(canvas), do: canvas
end
