defmodule WhaleChat.Online do
  @moduledoc false

  alias Ecto.Adapters.SQL
  alias WhaleChat.Repo

  def summary do
    now = System.system_time(:second)
    cutoff = now - 180

    {player_count, visible_max, updated} =
      case aggregate_server_counts(cutoff, now) do
        {players, slots, updated_at} when players > 0 and slots > 0 ->
          {players, slots, updated_at}

        _ ->
          fallback_online_count(now)
      end

    %{
      success: true,
      player_count: max(player_count, 0),
      visible_max: if(visible_max > 0, do: visible_max, else: 32),
      updated: updated
    }
  end

  defp aggregate_server_counts(cutoff, now) do
    sql = """
    SELECT
      COALESCE(SUM(playercount), 0) AS total_players,
      COALESCE(SUM(visible_max), 0) AS total_slots,
      COALESCE(MAX(last_update), ?) AS last_update
    FROM whaletracker_servers
    WHERE last_update >= ?
    """

    case SQL.query(Repo, sql, [now, cutoff]) do
      {:ok, %{rows: [[players, slots, updated]]}} ->
        {to_int(players), to_int(slots), to_int(updated, now)}

      _ ->
        {0, 0, now}
    end
  rescue
    _ -> {0, 0, now}
  end

  defp fallback_online_count(now) do
    case SQL.query(Repo, "SELECT COUNT(*) AS total_players FROM whaletracker_online", []) do
      {:ok, %{rows: [[players]]}} -> {to_int(players), 32, now}
      _ -> {0, 32, now}
    end
  rescue
    _ -> {0, 32, now}
  end

  defp to_int(value, default \\ 0)
  defp to_int(nil, default), do: default
  defp to_int(value, _default) when is_integer(value), do: value
  defp to_int(value, _default) when is_float(value), do: trunc(value)

  defp to_int(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      _ -> default
    end
  end

  defp to_int(_, default), do: default
end
