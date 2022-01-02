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
        movies: :boolean,
        movie_id: :integer,
        details: :boolean,
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
        m: :movies,
        id: :movie_id,
        d: :details,
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
            movies: true,
            movie_id: 1,
            details: false,
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
    
      -h  --help            Provides help information for torrent client
      -m  --movies          Provides markup for client to search for torrent data
      -id --movie_id        Chooses id to search for movie details. Type integer
      -d  --details         Provides markup for client to search for movie details
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
    query =
      cond do
        params[:movies] ->
          term = if keyword == "", do: 0, else: keyword

          @torrent <>
            "list_movies.json?query_term=#{term}&limit=#{params[:limit]}&page=#{params[:page]}&quality=#{params[:quality]}&minimum_rating=#{params[:minimum_rating]}&order_by=#{params[:order_by]}&sort_by=#{params[:sort_by]}&genre=#{params[:genre]}"

        params[:details] ->
          @torrent <> "movie_details.json?movie_id#{params[:movie_id]}"

        true ->
          process([Keyword.merge(params, movies: true), [keyword]])
      end

    Torrent.Client.fetch(query)
    |> Torrent.TableFormatter.print_table_for_columns(@headers)
  end
end
