import Atomics

extension GitHubPlugin
{
    final
    class Counters:Sendable
    {
        let reposCrawled:UnsafeAtomic<Int>
        let reposUpdated:UnsafeAtomic<Int>
        let tagsCrawled:UnsafeAtomic<Int>
        let tagsUpdated:UnsafeAtomic<Int>
        let errors:UnsafeAtomic<Int>

        init()
        {
            self.reposCrawled = .create(0)
            self.reposUpdated = .create(0)
            self.tagsCrawled = .create(0)
            self.tagsUpdated = .create(0)
            self.errors = .create(0)
        }

        deinit
        {
            self.reposCrawled.destroy()
            self.reposUpdated.destroy()
            self.tagsCrawled.destroy()
            self.tagsUpdated.destroy()
            self.errors.destroy()
        }
    }
}
