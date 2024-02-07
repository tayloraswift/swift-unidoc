extension Timestamp
{
    @frozen public
    struct Time:Equatable, Hashable, Sendable
    {
        public
        var hour:Int32
        public
        var minute:Int32
        public
        var second:Int32

        @inlinable public
        init(hour:Int32, minute:Int32, second:Int32)
        {
            self.hour = hour
            self.minute = minute
            self.second = second
        }
    }
}
extension Timestamp.Time
{
    @inlinable public static
    var midnight:Self { .init(hour: 0, minute: 0, second: 0) }
}
extension Timestamp.Time:CustomStringConvertible
{
    /// Formats the time as `hh:mm:ss`.
    @inlinable public
    var description:String { "\(self.hh):\(self.mm):\(self.ss)" }
}
extension Timestamp.Time
{
    @inlinable public
    var hh:String { self.hour < 10 ? "0\(self.hour)" : "\(self.hour)" }

    @inlinable public
    var mm:String { self.minute < 10 ? "0\(self.minute)" : "\(self.minute)" }

    @inlinable public
    var ss:String { self.second < 10 ? "0\(self.second)" : "\(self.second)" }
}
