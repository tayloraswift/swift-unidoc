extension Timestamp
{
    @frozen public
    struct Year:RawRepresentable, Equatable, Hashable, Sendable
    {
        public
        var rawValue:Int32

        @inlinable public
        init(rawValue:Int32)
        {
            self.rawValue = rawValue
        }
    }
}
extension Timestamp.Year:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:Int32) { self.init(rawValue: integerLiteral) }
}
extension Timestamp.Year:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension Timestamp.Year:Strideable
{
    @inlinable public
    func distance(to other:Self) -> Int
    {
        self.rawValue.distance(to: other.rawValue)
    }

    @inlinable public
    func advanced(by stride:Int) -> Self
    {
        .init(rawValue: self.rawValue.advanced(by: stride))
    }
}
extension Timestamp.Year
{
    @inlinable public
    var predecessor:Self { self.advanced(by: -1) }

    @inlinable public
    var successor:Self { self.advanced(by: 1) }
}
extension Timestamp.Year:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.rawValue)" }
}
extension Timestamp.Year:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        guard
        let rawValue:Int32 = .init(description)
        else
        {
            return nil
        }

        self.init(rawValue: rawValue)
    }
}
extension Timestamp.Year
{
    @inlinable public
    var vibe:(start:Timestamp.Weekday, leap:Bool)
    {
        /// https://en.wikipedia.org/wiki/Doomsday_rule
        /// https://en.wikipedia.org/wiki/Leap_year#Algorithm
        let y:Int = .init(self.rawValue)

        let i:(Int, Int) = y.quotientAndRemainder(dividingBy: 4)
        let j:(Int, Int) = y.quotientAndRemainder(dividingBy: 100)
        let k:(Int, Int) = y.quotientAndRemainder(dividingBy: 400)

        let leap:Bool = k.1 == 0 || j.1 != 0 && i.1 == 0
        let base:Timestamp.Weekday = leap ? .saturday : .sunday
        return (base.advanced(by: y + i.0 - j.0 + k.0), leap)
    }
}
