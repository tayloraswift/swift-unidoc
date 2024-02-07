import HTML
import UnixTime

extension Swiftinit
{
    struct EventTime
    {
        let stamp:Timestamp.Components
        let age:Swiftinit.Age

        init(stamp:Timestamp.Components, age:Swiftinit.Age)
        {
            self.stamp = stamp
            self.age = age
        }
    }
}
extension Swiftinit.EventTime:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.time]
        {
            $0.datetime = """
            \(self.stamp.date)T\(self.stamp.time)Z
            """
        } = "\(self.stamp.date) \(self.stamp.time)"

        html[.span] { $0.class = "parenthetical" } = self.age.long
    }
}
