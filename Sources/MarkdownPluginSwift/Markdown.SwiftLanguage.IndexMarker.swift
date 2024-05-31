import Symbols

extension Markdown.SwiftLanguage
{
    @frozen public
    struct IndexMarker
    {
        public
        let symbol:Symbol.USR
        public
        let phylum:Phylum.Decl?

        @inlinable public
        init(symbol:Symbol.USR, phylum:Phylum.Decl?)
        {
            self.symbol = symbol
            self.phylum = phylum
        }
    }
}
extension Markdown.SwiftLanguage.IndexMarker:CustomStringConvertible
{
    public
    var description:String
    {
        "(\(self.phylum?.name ?? "unknown"): \(self.symbol))"
    }
}
