import HTML
import ISO
import UnixCalendar

extension Unidoc {
    struct Byline: Equatable, Sendable {
        let published: Timestamp
        let locale: ISO.Locale

        init(published: Timestamp, locale: ISO.Locale) {
            self.published = published
            self.locale = locale
        }
    }
}
extension Unidoc.Byline: HTML.OutputStreamable {
    static func |= (time: inout HTML.AttributeEncoder, self: Self) {
        time.datetime = "\(self.published.date)"
    }

    static func += (time: inout HTML.ContentEncoder, self: Self) {
        time += "Published "
        time += self.published.date.short(self.locale)
    }
}
