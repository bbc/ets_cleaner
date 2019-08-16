Mox.defmock(EtsCleaner.SystemMemoryMock, for: EtsCleaner.SystemMemory)
Mox.defmock(FakeCleanerMock, for: EtsCleaner.ICleanEtsTables)

ExUnit.start()
