defmodule Torrent.Client do
  @scraperapi_url Application.get_env(:torrent_client, :scraper_api)
  @api_key Application.get_env(:torrent_client, :api_key)
  @baseUrl "#{@scraperapi_url}api_key=#{@api_key}&autoparse=true"
  @torrentUrl "https://pirate-bays.net/search?q="

  def fetch(query) do
    String.split(query)
    |> Enum.join("+")
    |> request()
  end

  def request(params) do
    @baseUrl <> "&url=" <> @torrentUrl <> params
  end
end
