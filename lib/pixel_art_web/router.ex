defmodule PixelArtWeb.Router do
  use PixelArtWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PixelArtWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/:topic", CanvasLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", PixelArtWeb do
  #   pipe_through :api
  # end
end
