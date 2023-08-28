import UnidocRecords

extension Volume.Noun
{
    @frozen public
    enum Locality:UInt8, Equatable, Hashable, Sendable
    {
        case culture = 0x01
        case package = 0x02
    }
}
