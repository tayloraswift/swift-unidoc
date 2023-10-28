import Atomics

extension Server
{
    struct Counters:~Copyable
    {
        let requestsDropped:UnsafeAtomic<Int>

        let errorsCrawling:UnsafeAtomic<Int>
        let reposCrawled:UnsafeAtomic<Int>
        let reposUpdated:UnsafeAtomic<Int>
        let tagsCrawled:UnsafeAtomic<Int>
        let tagsUpdated:UnsafeAtomic<Int>

        init()
        {
            self.requestsDropped = .create(0)

            self.errorsCrawling = .create(0)
            self.reposCrawled = .create(0)
            self.reposUpdated = .create(0)
            self.tagsCrawled = .create(0)
            self.tagsUpdated = .create(0)
        }

        deinit
        {
            self.requestsDropped.destroy()

            self.errorsCrawling.destroy()
            self.reposCrawled.destroy()
            self.reposUpdated.destroy()
            self.tagsCrawled.destroy()
            self.tagsUpdated.destroy()
        }
    }
}
