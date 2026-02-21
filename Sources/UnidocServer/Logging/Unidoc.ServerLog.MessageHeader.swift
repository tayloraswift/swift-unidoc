import HTML
import UnidocUI
import UnixCalendar
import UnixTime

extension Unidoc.ServerLog {
    @frozen @usableFromInline struct MessageHeader {
        @usableFromInline let components: Timestamp.Components
        @usableFromInline let dynamicAge: DurationFormat

        @inlinable init(components: Timestamp.Components, dynamicAge: DurationFormat) {
            self.components = components
            self.dynamicAge = dynamicAge
        }
    }
}
extension Unidoc.ServerLog.MessageHeader: HTML.OutputStreamable {
    @inlinable static func += (div: inout HTML.ContentEncoder, self: Self) {
        div[.time] {
            $0.datetime = """
            \(self.components.date)T\(self.components.time)Z
            """
        } = "\(self.components.date) \(self.components.time)"

        div[.span] { $0.class = "parenthetical" } = "\(self.dynamicAge) ago"
    }
}
