import HTML
import UnixTime

extension Swiftinit.PackagesCrawledPage
{
    enum DateLabel
    {
        case dm(Int32, Timestamp.Month)
        case md(Timestamp.Month, Int32)
    }
}
extension Swiftinit.PackagesCrawledPage.DateLabel:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        switch self
        {
        case let .dm(day, month):
            html[.span] { $0.class = "d" } = "\(day)"
            html[.span] { $0.class = "m" } = "/\(month)"

        case let .md(month, day):
            html[.span] { $0.class = "m" } = "\(month)/"
            html[.span] { $0.class = "d" } = "\(day)"
        }
    }
}
