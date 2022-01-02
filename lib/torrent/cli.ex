defmodule Torrent.Cli do
  @torrent Application.get_env(:torrent_client, :ytx_url)
  @defyear Date.utc_today().year

  # https://yts.mx/browse-movies/christmas/1080p/romance/5/latest/2021/en
  # https://yts.mx/browse-movies/0/all/all/0/latest/2021/all

  def parse_args(args) do
    OptionParser.parse(args,
      switches: [
        help: :boolean,
        quality: :string,
        genre: :string,
        rating: :integer,
        order: :string,
        year: :integer,
        language: :string
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
            quality: "all",
            genre: "all",
            rating: "all",
            order: "latest",
            year: @defyear,
            language: "en"
          ],
          parsed
        ),
        args
      ]
    end
  end

  def args_to_internal_representation(_), do: :help

  def process(:help) do
    IO.puts(
      "usage: escript ./torrent-client <keyword | search> [ --(quality, genre, rating | @defualt 'all'), order | @default 'latest', year | @default #{@defyear}, language | @default 'en' ]"
    )

    System.halt(0)
  end

  def process([params, search]) do
    # https://yts.mx/browse-movies/christmas/1080p/romance/5/latest/2021/en
    # https://yts.mx/browse-movies/0/all/all/0/latest/2021/all
    IO.inspect(
      '#{@torrent}#{Enum.join(search, "%20")}/#{params[:quality]}/#{params[:genre]}/#{params[:rating]}/#{params[:order]}/#{params[:year]}/#{params[:language]}'
    )

    # Torrent.Client.fetch(query)
    # |> decode_response()
    # |> sort_into_descending_order()
    # |> last(count)
    # |> print_table_for_columns(["number", "created_at", "title"])
  end
end
