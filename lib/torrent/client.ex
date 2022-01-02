defmodule Torrent.Client do
  @scraperapi_url Application.get_env(:torrent_client, :scraper_api)
  @api_key Application.get_env(:torrent_client, :api_key)
  @baseUrl "#{@scraperapi_url}api_key=#{@api_key}&autoparse=true"
  @ytxapi Application.get_env(:torrent_cli, :ytx_url)
  @torrentUrl "https://pirate-bays.net/search?q="

  # https://yts.mx/browse-movies/christmas/1080p/romance/5/latest/2021/en

  def fetch(query) do
    query
    |> HTTPoison.get()
    |> handle_response()
    |> IO.inspect()
  end

  def handle_response({:ok, response}) do
    IO.inspect("here")
    {:ok, document} = Floki.parse_document(response.body)
    IO.inspect(document, label: :document)
    Floki.find(document, ".browse-movie-title")
  end

  def handle_response({:error, _}) do
    IO.inspect("there")
    {:error, :error}
  end

  # def handle_reponse(other), do: {:error, other}
end
