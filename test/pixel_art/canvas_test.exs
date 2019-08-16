defmodule PixelArt.CanvasTest do
  use ExUnit.Case, async: true
  alias PixelArt.Canvas

  setup do
    {:ok, canvas: Canvas.new()}
  end

  test "get/2 returns white by default", %{canvas: canvas} do
    assert Canvas.get(canvas, {10, 10}) == {255, 255, 255}
  end

  test "get/2 errors for OOB", %{canvas: canvas} do
    catch_error(Canvas.get(canvas, {-1, -1}))
  end

  test "put/3 updates the color", %{canvas: canvas} do
    coordinate = {10, 10}
    color = {1, 2, 3}
    canvas = Canvas.put(canvas, coordinate, color)

    assert Canvas.get(canvas, coordinate) == color
  end

  test "put/3 errors for OOB", %{canvas: canvas} do
    catch_error(Canvas.put(canvas, {-1, -1}, {10, 10, 10}))
  end

  test "put/3 errors for OOB color", %{canvas: canvas} do
    catch_error(Canvas.put(canvas, {10, 10}, {258, 10, 10}))
  end

  test "list/1 returns sparse map of colors", %{canvas: canvas} do
    data = %{{10, 10} => {1, 2, 3}, {20, 20} => {0, 0, 0}}

    canvas =
      Enum.reduce(data, canvas, fn {coordinate, color}, canvas ->
        Canvas.put(canvas, coordinate, color)
      end)

    assert Canvas.list(canvas) == data
  end
end
