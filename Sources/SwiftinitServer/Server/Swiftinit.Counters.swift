import Atomics

extension Swiftinit
{
    struct Counters:~Copyable
    {
        let requestsDropped:UnsafeAtomic<Int>

        /// Has units of milliseconds, but we don’t have a way to type that with `UnsafeAtomic`.
        let averagePackageStaleness:UnsafeAtomic<Int>
        let errorsCrawling:UnsafeAtomic<Int>
        let reposCrawled:UnsafeAtomic<Int>
        let reposUpdated:UnsafeAtomic<Int>
        let tagsCrawled:UnsafeAtomic<Int>
        let tagsUpdated:UnsafeAtomic<Int>

        init()
        {
            self.requestsDropped = .create(0)

            self.averagePackageStaleness = .create(0)
            self.errorsCrawling = .create(0)
            self.reposCrawled = .create(0)
            self.reposUpdated = .create(0)
            self.tagsCrawled = .create(0)
            self.tagsUpdated = .create(0)
        }

        deinit
        {
            self.requestsDropped.destroy()

            self.averagePackageStaleness.destroy()
            self.errorsCrawling.destroy()
            self.reposCrawled.destroy()
            self.reposUpdated.destroy()
            self.tagsCrawled.destroy()
            self.tagsUpdated.destroy()
        }
    }
}
