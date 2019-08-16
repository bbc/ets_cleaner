defmodule EtsCleaner do
  use GenServer

  @system_memory Application.get_env(:ets_cleaner, :system_memory)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :local_cache_cleaner)
  end

  def init(init_state = [cleaner_module: _cleaner_module, check_interval: check_interval]) do
    schedule_work(check_interval)
    {:ok, init_state}
  end

  def handle_info(
        :refresh,
        state = [cleaner_module: cleaner_module, check_interval: check_interval]
      ) do
    @system_memory.mem_percent_used()
    |> cleaner_module.clean()

    schedule_work(check_interval)
    {:noreply, state}
  end

  # Catch all to handle unexpected messages
  # https://elixir-lang.org/getting-started/mix-otp/genserver.html#call-cast-or-info
  def handle_info(_any_message, state) do
    {:noreply, state}
  end

  defp schedule_work(check_interval), do: Process.send_after(self(), :refresh, check_interval)
end
