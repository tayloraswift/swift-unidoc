import Testing

protocol ParsingSuite
{
    associatedtype Format:Equatable & LosslessStringConvertible
}
extension ParsingSuite
{
    static func roundtrip(_ expression:String) throws -> Format
    {
        let value:Format = try #require(.init(expression))
        #expect(value == Format.init("\(value)"))
        return value
    }
}
