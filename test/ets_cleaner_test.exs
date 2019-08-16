defmodule EtsCleanerTest do
  use ExUnit.Case
  import Mox
  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    EtsCleaner.start_link(cleaner_module: FakeCleanerMock, check_interval: 100)
    :ok
  end

  test "calls to get memory usage and the provided clean callback module were made" do
    EtsCleaner.SystemMemoryMock
    |> expect(:mem_percent_used, fn -> 50 end)

    FakeCleanerMock
    |> expect(:clean, fn 50 -> :ok end)

    :timer.sleep(120)
  end
end
