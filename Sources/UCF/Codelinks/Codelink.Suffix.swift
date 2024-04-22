import FNV1

extension Codelink
{
    @frozen public
    enum Suffix:Equatable, Hashable, Sendable
    {
        case legacy(Legacy)
        case filter(Filter)
        case hash(FNV24)
    }
}
