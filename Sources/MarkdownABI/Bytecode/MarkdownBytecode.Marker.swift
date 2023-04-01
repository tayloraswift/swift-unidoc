extension MarkdownBytecode
{
    @frozen public
    enum Marker:UInt8, Equatable, Hashable, Sendable
    {
        case attribute = 0xC0
        case reference = 0xC1

        case reserved = 0xF5

        case emit = 0xFD
        case push = 0xFE
        case pop = 0xFF
    }
}
extension MarkdownBytecode.Marker
{
    @inlinable public
    init(_ value:UInt8)
    {
        self = .init(rawValue: value) ?? .reserved
    }
}
