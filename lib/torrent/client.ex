defmodule Torrent.Client do
  @scraperapi_url Application.get_env(:torrent_client, :scraper_api)
  @api_key Application.get_env(:torrent_client, :api_key)
  @baseUrl "#{@scraperapi_url}api_key=#{@api_key}&autoparse=true"
  @ytxapi Application.get_env(:torrent_cli, :ytx_url)
  @torrentUrl "https://pirate-bays.net/search?q="
  @headers Application.get_env(:torrent_cli, :headers)

  # https://yts.mx/browse-movies/christmas/1080p/romance/5/latest/2021/en

  def fetch(query) do
    query
    |> HTTPoison.get()
    |> handle_response()
  end

  def handle_response({:ok, response}) do
    Poison.Parser.parse!(response.body)
    |> Map.get("data")
    |> Map.get("movies")
    |> Enum.map(
      fn movie ->
        Map.take(movie, @headers)
      end
    )
  end

  def handle_response({:error, _}), do: {:error}
end
