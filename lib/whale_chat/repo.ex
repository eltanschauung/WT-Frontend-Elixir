defmodule WhaleChat.Repo do
  use Ecto.Repo,
    otp_app: :whale_chat,
    adapter: Ecto.Adapters.MyXQL
end
