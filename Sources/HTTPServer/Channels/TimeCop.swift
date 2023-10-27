import Atomics

struct TimeCop:~Copyable, Sendable
{
    let epoch:UnsafeAtomic<UInt>

    init()
    {
        self.epoch = .create(0)
    }

    deinit
    {
        self.epoch.destroy()
    }
}
extension TimeCop
{
    func reset()
    {
        self.epoch.wrappingIncrement(ordering: .relaxed)
    }

    func start(interval:Duration = .milliseconds(1000)) async throws
    {
        var epoch:UInt = 0
        while true
        {
            try await Task.sleep(for: interval)

            switch self.epoch.load(ordering: .relaxed)
            {
            case epoch:
                //  The epoch hasn’t changed, so we should enforce the timeout.
                return

            case let new:
                //  The epoch has changed, so let’s wait another `interval`.
                epoch = new
            }
        }
    }
}
