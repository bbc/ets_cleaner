use Mix.Config

config :ets_cleaner, system_memory: EtsCleaner.SystemMemory

import_config "#{Mix.env()}.exs"
