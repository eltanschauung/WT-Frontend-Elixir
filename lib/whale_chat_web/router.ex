defmodule WhaleChatWeb.Router do
  use WhaleChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WhaleChatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WhaleChatWeb.Plugs.ChatIdentity
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :chat_api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug WhaleChatWeb.Plugs.ChatIdentity
  end

  scope "/", WhaleChatWeb do
    pipe_through :browser

    live "/", ChatLive
  end

  scope "/stats", WhaleChatWeb do
    pipe_through :chat_api

    get "/chat.php", ChatApiController, :index
    post "/chat.php", ChatApiController, :create
    get "/online_summary.php", OnlineSummaryController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", WhaleChatWeb do
  #   pipe_through :api
  # end
end
