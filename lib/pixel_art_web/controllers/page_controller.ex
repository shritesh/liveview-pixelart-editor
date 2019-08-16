defmodule PixelArtWeb.PageController do
  use PixelArtWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
