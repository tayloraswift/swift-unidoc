import FNV1

extension UCF.Selector
{
    @frozen public
    enum Suffix:Equatable, Hashable, Sendable
    {
        case filter(UCF.KeywordFilter)
        case legacy(UCF.LegacyFilter, FNV24?)
        case hash(FNV24)
    }
}
