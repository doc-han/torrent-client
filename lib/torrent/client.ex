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

  def download(
        [
          %{"id" => movie_id, "summary" => _, "title_long" => title, "torrents" => torrents} =
            _movie
          | _
        ],
        movie_id,
        index
      ) do
    IO.inspect("config")
    hash = Enum.at(torrents, index) |> Map.get("hash")
    # curl - o localname.zip http: //example.com/download/myfile.zip
    System.cmd("curl", [
      "-o",
      "#{String.split(title) |> Enum.join("_")}.torrent",
      "https://yts.mx/torrent/download/#{hash}"
    ])
  end

  def download(
        [
          %{"id" => _, "summary" => _, "title_long" => _, "torrents" => _} = _
          | tail
        ],
        movie_id,
        index
      ) do
    download(tail, movie_id, index)
  end

  def download([], _, _), do: {:error, "No torrent found!!"}

  def handle_response({:ok, response}) do
    Poison.Parser.parse!(response.body)
    |> Map.get("data")
    |> Map.get("movies")
    |> Enum.map(fn movie ->
      Map.take(movie, ["id", "title_long", "torrents", "summary"])
    end)
    |> Enum.map(fn movie ->
      Map.update!(movie, "summary", &(String.slice(&1, 0..50) <> "..."))
    end)
  end

  def handle_response({:error, _}), do: {:error}

  def view(response) do
    Enum.map(response, fn movie ->
      Map.update!(movie, "torrents", fn existing ->
        Enum.reduce(existing, "", fn torrent, acc ->
          acc <> torrent["size"] <> " - " <> torrent["hash"] <> " * "
        end)
      end)
    end)
  end

  def torrent(response) do
    Enum.map(response, fn res ->
      Map.update!(res, "torrents", fn torrents ->
        Enum.with_index(torrents, fn torrent, index ->
          Map.merge(%{"index" => index}, Map.take(torrent, ["size", "hash"]))
        end)
      end)
    end)
  end
end
