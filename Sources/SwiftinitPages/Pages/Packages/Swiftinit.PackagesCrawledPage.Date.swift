import UnixTime

extension Swiftinit.PackagesCrawledPage
{
    struct Date
    {
        let crawled:UnixInstant?
        let repos:Int

        init(crawled:UnixInstant?, repos:Int)
        {
            self.crawled = crawled
            self.repos = repos
        }
    }
}
