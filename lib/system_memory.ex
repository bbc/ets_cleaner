defmodule EtsCleaner.SystemMemory do
  @callback mem_percent_used() :: integer()

  def mem_percent_used do
    memory_data = :memsup.get_system_memory_data()
    100 - memory_data[:free_memory] / memory_data[:total_memory] * 100
  end
end
