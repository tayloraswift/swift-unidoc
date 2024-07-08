import UnixTime

extension Unidoc.PackagesCrawledPage
{
    struct Date
    {
        let crawled:UnixAttosecond?
        let repos:Int

        init(crawled:UnixAttosecond?, repos:Int)
        {
            self.crawled = crawled
            self.repos = repos
        }
    }
}
