import FNV1
import Signatures
import Symbols
import Unidoc

extension Record.Master
{
    @frozen public
    struct Decl:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let signature:Signature<Unidoc.Scalar?>
        public
        let symbol:Symbol.Decl
        public
        let stem:Record.Stem

        public
        let superforms:[Unidoc.Scalar]
        public
        let culture:Unidoc.Scalar
        public
        let scope:[Unidoc.Scalar]

        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        @inlinable internal
        init(id:Unidoc.Scalar,
            signature:Signature<Unidoc.Scalar?>,
            symbol:Symbol.Decl,
            stem:Record.Stem,
            superforms:[Unidoc.Scalar],
            culture:Unidoc.Scalar,
            scope:[Unidoc.Scalar],
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil)
        {
            self.id = id
            self.signature = signature
            self.symbol = symbol
            self.stem = stem

            self.superforms = superforms
            self.culture = culture
            self.scope = scope

            self.overview = overview
            self.details = details
        }
    }
}
extension Record.Master.Decl
{
    @inlinable public
    var hash:FNV24
    {
        .init(hashing: "\(self.symbol)")
    }
}
