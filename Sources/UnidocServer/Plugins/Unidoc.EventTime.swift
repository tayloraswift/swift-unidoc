import HTML
import UnidocUI
import UnixCalendar

extension Unidoc
{
    @frozen @usableFromInline
    struct EventTime
    {
        @usableFromInline
        let components:Timestamp.Components
        @usableFromInline
        let dynamicAge:DurationFormat

        @inlinable
        init(components:Timestamp.Components, dynamicAge:DurationFormat)
        {
            self.components = components
            self.dynamicAge = dynamicAge
        }
    }
}
extension Unidoc.EventTime:HTML.OutputStreamable
{
    @inlinable static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.time]
        {
            $0.datetime = """
            \(self.components.date)T\(self.components.time)Z
            """
        } = "\(self.components.date) \(self.components.time)"

        html[.span] { $0.class = "parenthetical" } = "\(self.dynamicAge) ago"
    }
}
