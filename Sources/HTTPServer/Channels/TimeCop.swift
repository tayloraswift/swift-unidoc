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
    private static
    var deadbit:UInt { UInt.init(bitPattern: Int.min) }

    func reset()
    {
        self.epoch.wrappingIncrement(by: 2, ordering: .relaxed)
    }

    func pause<Success>(while body:() async throws -> Success) async throws -> Success
    {
        let epoch:UInt = self.epoch.wrappingIncrementThenLoad(ordering: .relaxed)
        if  epoch & Self.deadbit == 0
        {
            let value:Success = try await body()
            self.epoch.wrappingIncrement(ordering: .relaxed)
            return value
        }
        else
        {
            self.epoch.wrappingDecrement(ordering: .relaxed)
            throw CancellationError.init()
        }
    }

    func start(beat interval:Duration = .milliseconds(1000)) async throws
    {
        var epoch:UInt = 0
        while true
        {
            try await Task.sleep(for: interval)

            switch self.epoch.load(ordering: .relaxed)
            {
            case epoch:
                guard epoch & 1 == 0
                else
                {
                    //  The epoch hasn’t changed, but we’re paused.
                    continue
                }
                //  The epoch hasn’t changed, so we should enforce the timeout.
                //  We also need to mark the epoch as expired.
                _ = self.epoch.bitwiseOrThenLoad(with: Self.deadbit, ordering: .relaxed)
                return

            case let new:
                //  The epoch has changed, so let’s wait another `interval`.
                epoch = new
            }
        }
    }
}
