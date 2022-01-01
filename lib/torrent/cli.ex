defmodule Torrent.Cli do
  @default_options_count 5

  def parse_args(args) do
    OptionParser.parse(args,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  def run(args) do
    args
    |> parse_args
    |> process()
  end

  def args_to_internal_representation([query]) do
    query
  end

  def args_to_internal_representation(_), do: :help

  def process(:help) do
    IO.puts("usage: torrent-client <filename> [ options-count | #{@default_options_count} ]")
    System.halt(0)
  end

  def process(query) do
    Torrent.Client.fetch(query)
    # |> decode_response()
    # |> sort_into_descending_order()
    # |> last(count)
    # |> print_table_for_columns(["number", "created_at", "title"])
  end
end
