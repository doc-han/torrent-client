# Torrent Client

Torrent Client is a new client command-line system for dowloading torrents for movies focusing on **speed** and **reliability**.

Torrent Client takes several approaches to downloading torrents for the yts api.

Torrent Client uses extensive [sub binary matching][1], a built on **Poison Parser**.

Torrent Client benchmarks sometimes puts Torrent Client's performance close to `jiffy` and
usually faster than other Erlang/Elixir libraries.

Torrent Client fully conforms to [RFC 7159][4], [ECMA 404][5], and fully passes the
[JSONTestSuite][6].

## Installation

First, add Torrent Client to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:httpoison, "~> 1.8.0"},
    {:poison, "~> 5.0.0"},
    {:ex_doc, "~> 0.26.0"},
    {:earmark, "~> 1.4"},
    {:floki, "~> 0.32.0"}
  ]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

## Usage

```elixir
Torrent Client.!(%{"age" => 27, "name" => "Devin Torres"})
#=> "{\"name\":\"Devin Torres\",\"age\":27}"
```

usage: escript ./torrent_client [options | args]

## Example:

        escript ./torrent_client -v Spider Man -s year -o desc
        escript ./torrent_client -t Spider Man --limit 3 --genre Action
        escript ./torrent_client -d Spider Man --movie_id 38423 --index 0

      -h  --help            Provides help information for torrent client
      -v  --view            Views query results matching specified parameters
      -m  --movies          Provides markup for client to search for torrent data
      -t  --torrents        Retrieves torrent file with movie name for downloads
      -i  --movie_id         Chooses id to search for movie details. Type integer
      -d  --downloads       Downloads torrent file for specified movie index
      -l  --limit           Sets limit for number of search results retrieved
      -q  --quality         Quality of movies to be queried [720p | 1080p | 2160p | 3D]
      -p  --page            Provides page number for search query
      -g  --genre           Genre of movies to be queried
      -mr --minimum_rating  Provides minimum rating of movies
      -o  --order_by        Order for search results [desc | asc]
      -s  --sort_by         Sorting order for search results [title | year | rating | peers | seeds | download_count | like_count | date_added]

"""

````elixir


### Key Validation

```iex

````

## Benchmarking

```sh-session
$ MIX_ENV=bench mix run bench/run.exs
```
