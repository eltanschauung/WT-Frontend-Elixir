defmodule WhaleChatWeb.MapsDbController do
  use WhaleChatWeb, :controller

  alias WhaleChat.MapsDb

  def index(conn, _params) do
    steamid = get_session(conn, "steamid")
    data = MapsDb.page_data(steamid)

    render(conn, :index,
      mapsdb: data,
      chart_json: Jason.encode!(data.popularity_chart),
      map_sections: data.map_sections,
      popular_maps: data.popular_maps,
      map_previews: data.map_previews
    )
  end
end
