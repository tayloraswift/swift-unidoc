import BSON

extension Unidoc.Stats
{
    @frozen public
    struct Coverage:Equatable, Sendable
    {
        /// Declarations with no documentation whatsoever.
        public
        var undocumented:Int
        /// Declarations with no documentation but have at least one documented relative.
        public
        var indirect:Int
        /// Declarations with documentation.
        public
        var direct:Int

        @inlinable public
        init(undocumented:Int, indirect:Int, direct:Int)
        {
            self.undocumented = undocumented
            self.indirect = indirect
            self.direct = direct
        }
    }
}
extension Unidoc.Stats.Coverage:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(CodingKey, Never)...)
    {
        self.init(undocumented: 0, indirect: 0, direct: 0)
    }
}
extension Unidoc.Stats.Coverage:Unidoc.StatsCounters,
    BSONDocumentEncodable,
    BSONDocumentDecodable
{
    @frozen public
    enum CodingKey:String, Sendable, CaseIterable
    {
        case undocumented = "U"
        case indirect = "I"
        case direct = "D"
    }

    @inlinable public static
    subscript(key:CodingKey) -> WritableKeyPath<Self, Int>
    {
        switch key
        {
        case .undocumented: \.undocumented
        case .indirect:     \.indirect
        case .direct:       \.direct
        }
    }
}
