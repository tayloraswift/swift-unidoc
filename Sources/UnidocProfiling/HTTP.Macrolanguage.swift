import HTTP

extension HTTP
{
    @available(*, unavailable, message: "Needs a macro.")
    @frozen public
    struct Macrolanguage:Equatable, Hashable, Sendable
    {
        public
        var rawValue:UInt16

        @inlinable public
        init(rawValue:UInt16)
        {
            self.rawValue = rawValue
        }
    }
}
@available(*, unavailable)
extension HTTP.Macrolanguage:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        withUnsafeBytes(of: self.rawValue.bigEndian)
        {
            .init(decoding: $0, as: Unicode.ASCII.self)
        }
    }
}
@available(*, unavailable)
extension HTTP.Macrolanguage:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        guard description.utf8.count == 2
        else
        {
            return nil
        }

        self.init(rawValue: 0)

        for byte:UInt8 in description.utf8
        {
            self.rawValue <<= 8
            self.rawValue |= .init(byte)
        }
    }
}
