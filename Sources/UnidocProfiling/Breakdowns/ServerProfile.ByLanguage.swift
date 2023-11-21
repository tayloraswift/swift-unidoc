import HTTP
import Media

extension ServerProfile
{
    @frozen public
    struct ByLanguage
    {
        @usableFromInline internal
        var counts:[Macrolanguage: Int]

        @inlinable internal
        init(counts:[Macrolanguage: Int])
        {
            self.counts = counts
        }
    }
}
extension ServerProfile.ByLanguage:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(counts: [:])
    }
}
extension ServerProfile.ByLanguage
{
    @inlinable public
    subscript(language:Macrolanguage) -> Int
    {
        _read
        {
            yield  self.counts[language, default: 0]
        }
        _modify
        {
            yield &self.counts[language, default: 0]
        }
    }
}
extension ServerProfile.ByLanguage:PieValues
{
    public
    typealias SectorKey = Macrolanguage

    public
    var sectors:[(key:Macrolanguage, value:Int)]
    {
        self.counts.sorted { $0.key < $1.key }
    }
}
