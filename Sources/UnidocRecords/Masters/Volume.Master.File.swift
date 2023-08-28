import Unidoc
import Symbols

extension Volume.Master
{
    @frozen public
    struct File:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        let symbol:Symbol.File

        @inlinable public
        init(id:Unidoc.Scalar, symbol:Symbol.File)
        {
            self.id = id
            self.symbol = symbol
        }
    }
}
