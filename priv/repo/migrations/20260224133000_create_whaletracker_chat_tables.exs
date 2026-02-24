defmodule WhaleChat.Repo.Migrations.CreateWhaletrackerChatTables do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:whaletracker_chat) do
      add :created_at, :integer, null: false
      add :steamid, :string, size: 32
      add :personaname, :string, size: 128
      add :iphash, :string, size: 64
      add :message, :text, null: false
      add :server_ip, :string, size: 64
      add :server_port, :integer
      add :alert, :boolean, null: false, default: true
    end

    create index(:whaletracker_chat, [:created_at])

    create_if_not_exists table(:whaletracker_chat_outbox) do
      add :created_at, :integer, null: false
      add :iphash, :string, size: 64, null: false
      add :display_name, :string, size: 128, default: ""
      add :message, :text, null: false
      add :server_ip, :string, size: 64
      add :server_port, :integer
      add :delivered_to, :text
    end

    create index(:whaletracker_chat_outbox, [:created_at])

    create_if_not_exists table(:whaletracker_webnames, primary_key: false) do
      add :name, :string, size: 128
      add :color, :string, size: 32
    end
  end
end
