import Atomics

extension Server
{
    final
    class Counters:Sendable
    {
        let requestsDropped:UnsafeAtomic<Int>

        init()
        {
            self.requestsDropped = .create(0)
        }

        deinit
        {
            self.requestsDropped.destroy()
        }
    }
}
