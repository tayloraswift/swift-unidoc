import Symbols
import UnidocRecords

extension Selector
{
    @frozen public
    struct Precise:Equatable, Hashable, Sendable
    {
        public
        let symbol:Symbol.Decl

        @inlinable public
        init(_ symbol:Symbol.Decl)
        {
            self.symbol = symbol
        }
    }
}
