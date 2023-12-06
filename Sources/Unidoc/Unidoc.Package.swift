extension Unidoc
{
    @frozen public
    struct Package:RawRepresentable, Equatable, Hashable, Sendable
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
extension Unidoc.Package
{
    @inlinable public
    init(bits:UInt32)
    {
        self.init(rawValue: Int32.init(bitPattern: bits))
    }

    @inlinable public
    var bits:UInt32 { .init(bitPattern: self.rawValue) }
}
extension Unidoc.Package:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension Unidoc.Package:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:Int32) { self.init(rawValue: integerLiteral) }
}
extension Unidoc.Package:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.rawValue)" }
}
extension Unidoc.Package:LosslessStringConvertible
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
