defmodule EtsCleanerTest do
  use ExUnit.Case
  import Mox
  setup :verify_on_exit!
  setup :set_mox_global

  setup do
    # Define stubs so that the mocks exist when `EtsCleaner.init` is called
    EtsCleaner.SystemMemoryMock
    |> stub(:mem_percent_used, fn -> 20 end)

    FakeCleanerMock
    |> stub(:clean, fn _ -> :ok end)

    EtsCleaner.start_link(cleaner_module: FakeCleanerMock, check_interval: 100)
    :ok
  end

  test "calls to get memory usage and the provided clean callback module were made" do
    EtsCleaner.SystemMemoryMock
    |> expect(:mem_percent_used, fn -> 50 end)

    FakeCleanerMock
    |> expect(:clean, fn 50 -> :ok end)

    :timer.sleep(130)
  end

  test "call the cleaner twice when memory use is high" do
    EtsCleaner.SystemMemoryMock
    |> expect(:mem_percent_used, 2, fn -> 85 end)

    FakeCleanerMock
    |> expect(:clean, 2, fn 85 -> :ok end)

    :timer.sleep(130)
  end

  describe "scheduling work - when schedule is 60ms" do
    @provided_scheduled_work 60

    test "memory usage at 85% - should receive :refresh message within 20ms" do
      EtsCleaner.schedule_work(@provided_scheduled_work, 85)
      :timer.sleep(20)
      assert_received :refresh
    end

    test "memory usage at 75% - should receive :refresh message within 40ms" do
      EtsCleaner.schedule_work(@provided_scheduled_work, 75)
      :timer.sleep(40)
      assert_received :refresh
    end

    test "memory usage at 50% - should receive :refresh message within 70ms" do
      EtsCleaner.schedule_work(@provided_scheduled_work, 50)
      :timer.sleep(70)
      assert_received :refresh
    end
  end
end
