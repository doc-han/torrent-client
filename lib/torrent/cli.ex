defmodule Torrent.Cli do
  
  def parse_args(argv) do
    OptionParser.parse(argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
  end

  def run(argv) do
    argv
    |> parse_args
  end

  def process(:help) do
  end
end
