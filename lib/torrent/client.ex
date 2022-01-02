defmodule Torrent.Client do
  @scraperapi_url Application.get_env(:torrent_client, :scraper_api)
  @api_key Application.get_env(:torrent_client, :api_key)
  @baseUrl "#{@scraperapi_url}api_key=#{@api_key}&autoparse=true"
  @ytxapi Application.get_env(:torrent_cli, :ytx_url)
  @torrentUrl "https://pirate-bays.net/search?q="
  @headers Application.get_env(:torrent_cli, :headers)

  def fetch(query) do
    query
    |> HTTPoison.get()
    |> handle_response()
  end

  def handle_response({:ok, response}) do
    Poison.Parser.parse!(response.body)
    |> Map.get("data")
    |> Map.get("movies")
    |> Enum.map(fn movie ->
      Map.take(movie, ["id", "title_long", "rating", "torrents", "summary"])
    end)
    |> Enum.map(fn movie ->
      Map.update!(movie, "summary", &(String.slice(&1, 0..20) <> "..."))
    end)
    |> Enum.map(fn movie ->
      Map.update!(movie, "torrents", fn existing ->
        Enum.reduce(existing, "", fn torrent, acc ->
          acc <> torrent["size"] <> " - " <> torrent["hash"] <> " * "
        end)
      end)
    end)
  end

  def handle_response({:error, _}), do: {:error}
end
