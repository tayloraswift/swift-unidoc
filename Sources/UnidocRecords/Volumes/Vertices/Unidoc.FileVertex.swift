import Symbols
import Unidoc
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct FileVertex:Identifiable, Equatable, Sendable
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
