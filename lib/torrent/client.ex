defmodule Torrent.Client do
  @scraperapi_url Application.get_env(:torrent_client, :scraper_api)
  @api_key Application.get_env(:torrent_client, :api_key)
  @baseUrl "#{@scraperapi_url}api_key=#{@api_key}&autoparse=true"

  def fetch(query) do
    @baseUrl
  end
end
