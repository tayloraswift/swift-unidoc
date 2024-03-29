import BSON
import HTML
import UnixTime

extension Swiftinit
{
    struct PackageIndicators
    {
        private
        let pushed:BSON.Millisecond
        private
        let stars:Int
        private
        let now:UnixInstant

        init(pushed:BSON.Millisecond, stars:Int, now:UnixInstant)
        {
            self.pushed = pushed
            self.stars = stars
            self.now = now
        }
    }
}
extension Swiftinit.PackageIndicators:HTML.OutputStreamable
{
    static
    func += (span:inout HTML.ContentEncoder, self:Self)
    {
        let dynamicInterval:Duration.DynamicFormat = .init(
            truncating: self.now - .millisecond(self.pushed.value))

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
