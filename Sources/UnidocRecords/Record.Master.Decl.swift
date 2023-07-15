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
        let customization:Unidoc.Decl.Customization
        public
        let phylum:Unidoc.Decl
        public
        let route:Unidoc.Decl.Route

        public
        let signature:Signature<Unidoc.Scalar?>
        public
        let symbol:Symbol.Decl
        public
        let stem:Record.Stem

        public
        let superforms:[Unidoc.Scalar]
        public
        let namespace:Unidoc.Scalar
        public
        let culture:Unidoc.Scalar
        public
        let scope:[Unidoc.Scalar]

        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        @inlinable public
        init(id:Unidoc.Scalar,
            customization:Unidoc.Decl.Customization,
            phylum:Unidoc.Decl,
            route:Unidoc.Decl.Route,
            signature:Signature<Unidoc.Scalar?>,
            symbol:Symbol.Decl,
            stem:Record.Stem,
            superforms:[Unidoc.Scalar],
            namespace:Unidoc.Scalar,
            culture:Unidoc.Scalar,
            scope:[Unidoc.Scalar],
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil)
        {
            self.id = id
            self.customization = customization
            self.phylum = phylum
            self.route = route

            self.signature = signature
            self.symbol = symbol
            self.stem = stem

            self.superforms = superforms
            self.namespace = namespace
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
