use Mix.Config
config :torrent_client, api_key: "39ada2fa714a20c88ba24995f71a89c5"
config :torrent_client, scraper_api: "https://api.scraperapi.com?"
config :logger, compile_time_purge_info: :info
config :torrent_client, yts_api: "https://yts.mx/api/v2/"
config :torrent_client, headers: ["id", "title_long", "torrents", "summary"]
