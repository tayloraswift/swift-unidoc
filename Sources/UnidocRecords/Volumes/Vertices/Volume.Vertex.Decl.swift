import FNV1
import Signatures
import Sources
import Symbols
import Unidoc

extension Volume.Vertex
{
    @frozen public
    struct Decl:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let flags:Unidoc.Decl.Flags

        public
        let signature:Signature<Unidoc.Scalar?>
        public
        let symbol:Symbol.Decl
        public
        let stem:Volume.Stem

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
        var file:Unidoc.Scalar?
        //  TODO: consider combining this into flags.
        public
        var position:SourcePosition?
        public
        var overview:Volume.Passage?
        public
        var details:Volume.Passage?

        public
        var `extension`:Unidoc.Scalar?
        public
        var group:Unidoc.Scalar?

        @inlinable public
        init(id:Unidoc.Scalar,
            flags:Unidoc.Decl.Flags,
            signature:Signature<Unidoc.Scalar?>,
            symbol:Symbol.Decl,
            stem:Volume.Stem,
            requirements:[Unidoc.Scalar] = [],
            superforms:[Unidoc.Scalar] = [],
            namespace:Unidoc.Scalar,
            culture:Unidoc.Scalar,
            scope:[Unidoc.Scalar],
            file:Unidoc.Scalar? = nil,
            position:SourcePosition? = nil,
            overview:Volume.Passage? = nil,
            details:Volume.Passage? = nil,
            extension:Unidoc.Scalar? = nil,
            group:Unidoc.Scalar? = nil)
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
            self.file = file

            self.position = position
            self.overview = overview
            self.details = details
        }
    }
}
extension Volume.Vertex.Decl
{
    @inlinable public
    var location:SourceLocation<Unidoc.Scalar>?
    {
        if  let position:SourcePosition = self.position,
            let file:Unidoc.Scalar = self.file
        {
            return .init(position: position, file: file)
        }
        else
        {
            return nil
        }
    }

    @inlinable public
    var phylum:Unidoc.Decl
    {
        self.flags.phylum
    }

    @inlinable public
    var kinks:Unidoc.Decl.Kinks
    {
        self.flags.kinks
    }

    @inlinable public
    var shoot:Volume.Shoot
    {
        .init(
            stem: self.stem,
            hash: self.flags.route == .hashed ? .init(truncating: self.hash) : nil)
    }

    @inlinable internal
    var hash:FNV24.Extended
    {
        .init(hashing: "\(self.symbol)")
    }
}
