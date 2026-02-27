defmodule WhaleChatWeb.PageController do
  use WhaleChatWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def home(conn, _params) do
    render(conn, :home)
  end

  def whaletracker(conn, _params) do
    redirect(conn, to: "/stats")
  end
end
