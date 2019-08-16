defmodule EtsCleaner do
  use GenServer

  @system_memory Application.get_env(:ets_cleaner, :system_memory)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :local_cache_cleaner)
  end

  def init(init_state = [cleaner_module: _cleaner_module, check_interval: check_interval]) do
    IO.inspect(init_state, label: "initial state")
    system_memory = Application.get_env(:ets_cleaner, :system_memory)
    schedule_work(check_interval, system_memory.mem_percent_used())
    {:ok, init_state}
  end

  def handle_info(
        :refresh,
        state = [cleaner_module: cleaner_module, check_interval: check_interval]
      ) do
    @system_memory.mem_percent_used()
    |> cleaner_module.clean()

    schedule_work(check_interval, 80)
    {:noreply, state}
  end

  # Catch all to handle unexpected messages
  # https://elixir-lang.org/getting-started/mix-otp/genserver.html#call-cast-or-info
  def handle_info(_any_message, state) do
    {:noreply, state}
  end


  defp schedule_work(check_interval, mem_percent_used) when mem_percent_used >= 80 do
    Process.send_after(self(), :refresh, check_interval * 0.2)
  end

  defp schedule_work(check_interval, _mem_percent_used) do
    Process.send_after(self(), :refresh, check_interval)
  end
end
