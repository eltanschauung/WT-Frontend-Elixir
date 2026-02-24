defmodule WhaleChatWeb.PageController do
  use WhaleChatWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
