defmodule Torrent.Client do
  @scraperapi_url Application.get_env(:torrent_client, :scraper_api)
  @api_key Application.get_env(:torrent_client, :api_key)
  @baseUrl "#{@scraperapi_url}api_key=#{@api_key}&autoparse=true"
  @ytx_host Application.get_env(:torrent_cli, :ytx_url)
  @torrentUrl "https://pirate-bays.net/search?q="

  # https://yts.mx/browse-movies/christmas/1080p/romance/5/latest/2021/en

  def fetch(query) do
    String.split(query)
    |> Enum.join("+")
    |> request()
  end

  def request(params) do
    (@torrentUrl <> params)
    |> HTTPoison.get()
    |> handle_response()
  end

  def handle_response({:ok, response}) do
    response.body |> Poison.Parser.parse!()
  end

  def handle_response({:error, response}) do
    {:error, response}
  end

  def handle_reponse(_), do: {:error, :interface_error}

  def get_smoothies_url() do
    response = HTTPoison.get("https://yts.mx/browse-movies")

    {_, response_body} = response

    {:ok, document} = Floki.parse_document(response_body.body)
    # document
    # Floki.find(document, "a.fixed-recipe-card__title-link")
    Floki.find(document, ".browse-movie-title")
  end
end
