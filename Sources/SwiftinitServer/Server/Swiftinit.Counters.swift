import Atomics

extension Swiftinit
{
    struct Counters:~Copyable
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
