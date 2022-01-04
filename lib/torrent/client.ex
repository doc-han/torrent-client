defmodule Torrent.Client do
  @moduledoc """
    Provides functions for torrent client service

    fetch(query)      Makes a get request using the HTTPoison dependency to retrieves data
    download(movie_data, movie_id, torrent_index)
                      Downloads torrent file according to specified movie id and torrent index
    handle_response(response)
                      Poison parser parses the response data and retrieves relevant fields while
                      cleaning up certain options
    view(response)    Structures response data and makes it printable for table display
    torrent(reponse)  Structures response data and retrieves torrents data for json

  """

  @doc """
    Makes http get request using the HTTPoison dependency to retrieves data and pipes to the handle_response function

    This function takes a search query composed together with the yts api url and specified terms and keywords and
    returns parsed results of relevant fields

    ## Examples

      fetch("https://yts.mx/api/v2/query_term=Spider%20Man")
  """
  def fetch(query) do
    query
    |> HTTPoison.get()
    |> handle_response()
  end

  @doc """
  Downloads torrent file and returns no record found otherwise
  """
  def download(
        [
          %{"id" => movie_id, "summary" => _, "title_long" => title, "torrents" => torrents} =
            _movie
          | _
        ],
        movie_id,
        index
      ) do
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

  @doc """
  Poison parser parses the response data and retrieves relevant fields while
  """
  def handle_response({:ok, response}) do
    Poison.Parser.parse!(response.body)
    |> Map.get("data")
    |> Map.get("movies")
    |> Enum.map(fn movie ->
      Map.take(movie, ["id", "title_long", "torrents", "summary"])
    end)
    |> Enum.map(fn movie ->
      Map.update!(movie, "summary", &(String.slice(&1, 0..100) <> "..."))
    end)
  end

  def handle_response({:error, _}) do
    IO.inspect("Error: Please check network connection!")
    IO.puts("")
    Torrent.Cli.process(:help)
    System.halt(0)
  end

  @doc """
  Structures response data and makes it printable for table display
  """
  def view(response) do
    Enum.map(response, fn movie ->
      Map.update!(movie, "torrents", fn existing ->
        Enum.reduce(existing, "", fn torrent, acc ->
          acc <> torrent["size"] <> " - " <> torrent["hash"] <> " * "
        end)
      end)
    end)
  end

  @doc """
  Structures response data and retrieves torrents data for json
  """
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
