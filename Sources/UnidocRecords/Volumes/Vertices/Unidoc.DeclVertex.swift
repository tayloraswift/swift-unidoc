import FNV1
import Signatures
import Sources
import Symbols
import Unidoc
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct DeclVertex:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let flags:Phylum.DeclFlags

        public
        let signature:Signature<Unidoc.Scalar?>
        public
        let symbol:Symbol.Decl
        public
        let stem:Unidoc.Stem

        public
        let requirements:[Unidoc.Scalar]
        public
        let superforms:[Unidoc.Scalar]
        public
        let namespace:Unidoc.Scalar
        public
        let culture:Unidoc.Scalar
        public
        let scope:[Unidoc.Scalar]

        public
        var renamed:Unidoc.Scalar?
        public
        var readme:Unidoc.Scalar?
        public
        var file:Unidoc.Scalar?
        //  TODO: consider combining this into flags.
        public
        var position:SourcePosition?
        public
        var overview:Unidoc.Passage?
        public
        var details:Unidoc.Passage?

        public
        var `extension`:Unidoc.Group?
        public
        var group:Unidoc.Group?

        @inlinable public
        init(id:Unidoc.Scalar,
            flags:Phylum.DeclFlags,
            signature:Signature<Unidoc.Scalar?>,
            symbol:Symbol.Decl,
            stem:Unidoc.Stem,
            requirements:[Unidoc.Scalar] = [],
            superforms:[Unidoc.Scalar] = [],
            namespace:Unidoc.Scalar,
            culture:Unidoc.Scalar,
            scope:[Unidoc.Scalar],
            renamed:Unidoc.Scalar? = nil,
            readme:Unidoc.Scalar? = nil,
            file:Unidoc.Scalar? = nil,
            position:SourcePosition? = nil,
            overview:Unidoc.Passage? = nil,
            details:Unidoc.Passage? = nil,
            extension:Unidoc.Group? = nil,
            group:Unidoc.Group? = nil)
        {
            self.id = id
            self.flags = flags

            self.signature = signature
            self.symbol = symbol
            self.stem = stem

            self.requirements = requirements
            self.superforms = superforms
            self.namespace = namespace
            self.culture = culture
            self.scope = scope
            self.extension = `extension`
            self.group = group

            self.renamed = renamed
            self.readme = readme
            self.file = file
            self.position = position
            self.overview = overview
            self.details = details
        }
    }
}
extension Unidoc.DeclVertex:Unidoc.PrincipalVertex
{
    @inlinable public
    var route:Unidoc.Route
    {
        .init(shoot: self.shoot, cdecl: self.flags.language == .c)
    }

    @inlinable public
    var shoot:Unidoc.Shoot
    {
        .init(
            stem: self.stem,
            hash: self.flags.route == .hashed ? .init(truncating: self.hash) : nil)
    }

    @inlinable public
    var hash:FNV24.Extended { .init(hashing: "\(self.symbol)") }
}
extension Unidoc.DeclVertex
{
    @inlinable public
    var location:SourceLocation<Unidoc.Scalar>?
    {
        if  let position:SourcePosition = self.position,
            let file:Unidoc.Scalar = self.file
        {
            .init(position: position, file: file)
        }
        else
        {
            nil
        }
    }

    @inlinable public
    var phylum:Phylum.Decl
    {
        self.flags.phylum
    }

    @inlinable public
    var kinks:Phylum.Decl.Kinks
    {
        self.flags.kinks
    }
}
