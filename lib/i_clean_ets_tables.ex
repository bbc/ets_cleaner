defmodule EtsCleaner.ICleanEtsTables do
  @type percent_mem_used :: integer()

  @callback clean(percent_mem_used) :: :ok
end
