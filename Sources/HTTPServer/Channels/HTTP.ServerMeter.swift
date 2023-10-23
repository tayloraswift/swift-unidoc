import Atomics
import HTTP

extension HTTP
{
    public final
    class ServerMeter:Sendable
    {
        public
        let requests:UnsafeAtomic<Int>

        public
        init()
        {
            self.requests = .create(0)
        }

        deinit
        {
            self.requests.destroy()
        }
    }
}
