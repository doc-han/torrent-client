defmodule Torrent.Cli do
  @torrent Application.get_env(:torrent_client, :ytx_api)
  @headers Application.get_env(:torrent_client, :headers)

  # escript ./torrent_client --movie Christmas Tree --genre Comedy
  # https://yts.mx/browse-movies/christmas/1080p/romance/5/latest/2021/en
  # https://yts.mx/browse-movies/0/all/all/0/latest/2021/all

  def parse_args(args) do
    OptionParser.parse(args,
      switches: [
        help: :boolean,
        view: :boolean,
        index: :integer,
        download: :boolean,
        movie_id: :integer,
        torrents: :boolean,
        limit: :integer,
        page: :integer,
        quality: :string,
        genre: :string,
        minimum_rating: :integer,
        order_by: :string,
        sort_by: :string
      ],
      aliases: [
        h: :help,
        v: :view,
        d: :download,
        i: :movie_id,
        t: :torrents,
        l: :limit,
        p: :page,
        q: :quality,
        g: :genre,
        mr: :minimum_rating,
        o: :order_by,
        s: :sort_by
      ]
    )
    |> args_to_internal_representation()
  end

  def main(args) do
    args
    |> parse_args
    |> process()
  end

  def args_to_internal_representation({parsed, args, _}) do
    if :help in Keyword.keys(parsed) do
      :help
    else
      [
        Keyword.merge(
          [
            limit: 20,
            page: 1,
            quality: "all",
            genre: "all",
            minimum_rating: 0,
            order_by: "desc",
            sort_by: "year"
          ],
          parsed
        ),
        List.replace_at(
          [0],
          0,
          Enum.join(Enum.map(args, fn arg -> String.split(arg) |> Enum.join("%20") end), "%20")
        )
      ]
    end
  end

  def args_to_internal_representation(_), do: :help

  def process(:help) do
    IO.puts("""
      usage: escript ./torrent_client [options | args]
    
      Example:
        escript ./torrent_client -v Spider Man -s year -o desc
        escript ./torrent_client -t Spider Man --limit 3 --genre Action
        escript ./torrent_client -d Spider Man --movie_id 38423 --index 0
    
      -h  --help            Provides help information for torrent client
      -v  --view            Views query results matching specified parameters
      -m  --movies          Provides markup for client to search for torrent data
      -t  --torrents        Retrieves torrent file with movie name for downloads
      -i --movie_id        Chooses id to search for movie details. Type integer
      -d  --downloads       Downloads torrent file for specified movie index
      -l  --limit           Sets limit for number of search results retrieved
      -q  --quality         Quality of movies to be queried [720p | 1080p | 2160p | 3D]
      -p  --page            Provides page number for search query
      -g  --genre           Genre of movies to be queried
      -mr --minimum_rating  Provides minimum rating of movies
      -o  --order_by        Order for search results [desc | asc]
      -s  --sort_by         Sorting order for search results [title | year | rating | peers | seeds | download_count | like_count | date_added]
    """)

    System.halt(0)
  end

  def process([params, [keyword]]) do
    IO.inspect(params, label: keyword)

    movie_data =
      (@torrent <>
         "list_movies.json?query_term=#{if keyword == "", do: 0, else: keyword}&limit=#{params[:limit]}&page=#{params[:page]}&quality=#{params[:quality]}&minimum_rating=#{params[:minimum_rating]}&order_by=#{params[:order_by]}&sort_by=#{params[:sort_by]}&genre=#{params[:genre]}")
      |> Torrent.Client.fetch()

    cond do
      params[:torrents] ->
        Torrent.Client.torrent(movie_data) |> IO.inspect()

      params[:view] ->
        Torrent.TableFormatter.print_table_for_columns(movie_data, ["id", "title_long", "summary"])

      params[:download] ->
        Torrent.Client.download(
          Torrent.Client.torrent(movie_data),
          params[:movie_id],
          params[:index]
        )
    end
  end
end
