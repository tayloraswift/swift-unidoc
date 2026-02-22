import HTML
import UnixCalendar

extension Unidoc.PackagesCrawledPage {
    enum DateLabel {
        case dm(Int32, Timestamp.Month)
        case md(Timestamp.Month, Int32)
    }
}
extension Unidoc.PackagesCrawledPage.DateLabel: HTML.OutputStreamable {
    static func += (html: inout HTML.ContentEncoder, self: Self) {
        switch self {
        case let .dm(day, month):
            html[.span] { $0.class = "d" } = "\(day)"
            html[.span] { $0.class = "m" } = "/\(month)"

        case let .md(month, day):
            html[.span] { $0.class = "m" } = "\(month)/"
            html[.span] { $0.class = "d" } = "\(day)"
        }
    }
}
