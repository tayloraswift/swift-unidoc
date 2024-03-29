extension Unidoc
{
    @frozen public
    struct Version:RawRepresentable, Equatable, Hashable, Sendable
    {
        public
        let rawValue:Int32

        @inlinable public
        init(rawValue:Int32)
        {
            self.rawValue = rawValue
        }
    }
}
extension Unidoc.Version
{
    @inlinable public
    init(bits:UInt32)
    {
        self.init(rawValue: Int32.init(bitPattern: bits))
    }

    @inlinable public
    var bits:UInt32 { .init(bitPattern: self.rawValue) }
}
// extension Unidoc.Version
// {
//     @inlinable public static
//     var min:Self { .init(.min) }
//     @inlinable public static
//     var max:Self { .init(.max) }
// }
// extension Unidoc.Version:Comparable
// {
//     @inlinable public static
//     func < (a:Self, b:Self) -> Bool { a.bits < b.bits }
// }
extension Unidoc.Version:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:Int32) { self.init(rawValue: integerLiteral) }
}
extension Unidoc.Version:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.rawValue)" }
}
extension Unidoc.Version:LosslessStringConvertible
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
