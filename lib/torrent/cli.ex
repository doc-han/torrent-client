defmodule Torrent.Cli do
  @torrent Application.get_env(:torrent_client, :ytx_api)

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
      aliases: [h: :help]
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
    IO.puts(
      "usage: escript ./torrent-client <keyword | search> [ --(quality, genre, rating | @defualt 'all'), order | @default 'latest', year | @default current, language | @default 'en' ]"
    )

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
    # |> decode_response()
    # |> sort_into_descending_order()
    # |> last(count)
    # |> print_table_for_columns(["number", "created_at", "title"])
  end
end
