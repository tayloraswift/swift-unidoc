import UnidocRecords

extension Record.Noun
{
    @frozen public
    enum Race:UInt8, Equatable, Hashable, Sendable
    {
        case culture = 0x01
        case package = 0x02
    }
}
