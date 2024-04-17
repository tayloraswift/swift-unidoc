import HTML
import UnidocUI
import UnixTime

extension Unidoc
{
    struct EventTime
    {
        let components:Timestamp.Components
        let dynamicAge:Duration.DynamicFormat

        init(components:Timestamp.Components, dynamicAge:Duration.DynamicFormat)
        {
            self.components = components
            self.dynamicAge = dynamicAge
        }
    }
}
extension Unidoc.EventTime:HTML.OutputStreamable
{
    static
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
