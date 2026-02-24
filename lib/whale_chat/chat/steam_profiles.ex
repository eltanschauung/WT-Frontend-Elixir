defmodule WhaleChat.Chat.SteamProfiles do
  @moduledoc false

  @cache_table :whale_chat_steam_profile_cache
  @ttl_seconds 24 * 3600

  def fetch_many(steam_ids) when is_list(steam_ids) do
    ids =
      steam_ids
      |> Enum.filter(&is_binary/1)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.uniq()

    cond do
      ids == [] -> %{}
      steam_api_key() == "" -> %{}
      true -> cached_and_fetch(ids)
    end
  end

  def fetch_many(_), do: %{}

  defp cached_and_fetch(ids) do
    ensure_cache()
    now = System.system_time(:second)

    {cached, missing} =
      Enum.reduce(ids, {%{}, []}, fn sid, {acc, miss} ->
        case :ets.lookup(@cache_table, sid) do
          [{^sid, profile, expires_at}] when expires_at > now ->
            {Map.put(acc, sid, profile), miss}

          _ ->
            {acc, [sid | miss]}
        end
      end)

    fetched =
      missing
      |> Enum.reverse()
      |> Enum.chunk_every(100)
      |> Enum.reduce(%{}, fn chunk, acc -> Map.merge(acc, fetch_chunk(chunk)) end)

    Enum.each(fetched, fn {sid, profile} ->
      :ets.insert(@cache_table, {sid, profile, now + @ttl_seconds})
    end)

    Map.merge(cached, fetched)
  end

  defp fetch_chunk([]), do: %{}

  defp fetch_chunk(chunk) do
    ids = Enum.join(chunk, ",")

    url =
      "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{URI.encode(steam_api_key())}&steamids=#{URI.encode(ids)}"

    try do
      case Req.get(url, receive_timeout: 2_500, connect_options: [timeout: 2_500]) do
        {:ok, %{status: 200, body: %{"response" => %{"players" => players}}}} when is_list(players) ->
          Map.new(players, fn player ->
            sid = player["steamid"]
            {sid, %{"personaname" => player["personaname"], "avatarfull" => player["avatarfull"]}}
          end)

        _ ->
          %{}
      end
    rescue
      _ -> %{}
    end
  end

  defp steam_api_key, do: Application.get_env(:whale_chat, :steam_api_key, "")

  defp ensure_cache do
    case :ets.whereis(@cache_table) do
      :undefined -> :ets.new(@cache_table, [:named_table, :public, :set, read_concurrency: true])
      _ -> :ok
    end
  rescue
    _ -> :ok
  end
end
