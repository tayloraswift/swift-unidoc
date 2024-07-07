import HTML
import UnixTime

extension Unidoc.PackageChyron
{
    struct SocialMetrics
    {
        private
        let pushed:UnixMillisecond
        private
        let stars:Int
        private
        let now:UnixAttosecond

        init(pushed:UnixMillisecond, stars:Int, now:UnixAttosecond)
        {
            self.pushed = pushed
            self.stars = stars
            self.now = now
        }
    }
}
extension Unidoc.PackageChyron.SocialMetrics:HTML.OutputStreamable
{
    static
    func += (span:inout HTML.ContentEncoder, self:Self)
    {
        let dynamicInterval:Duration.DynamicFormat = .init(
            truncating: self.now - .init(self.pushed))

        span[.span]
        {
            $0.class = "pushed"
            $0.title = """
            This package’s repository was last pushed to \(dynamicInterval) ago.
            """
        } = "\(dynamicInterval.short)"

        span[.span]
        {
            $0.class = "stars"
            $0.title = """
            This package’s repository has
            \(self.stars) \(self.stars != 1 ? "stars" : "star").
            """
        } = "\(self.stars)"
    }
}
