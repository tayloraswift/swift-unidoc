import FNV1
import Signatures
import Sources
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
        let flags:Unidoc.Decl.Flags

        public
        let signature:Signature<Unidoc.Scalar?>
        public
        let symbol:Symbol.Decl
        public
        let stem:Record.Stem

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
        var group:Unidoc.Scalar?
        public
        var file:Unidoc.Scalar?
        //  TODO: consider combining this into flags.
        public
        var position:SourcePosition?
        public
        var overview:Record.Passage?
        public
        var details:Record.Passage?

        @inlinable public
        init(id:Unidoc.Scalar,
            flags:Unidoc.Decl.Flags,
            signature:Signature<Unidoc.Scalar?>,
            symbol:Symbol.Decl,
            stem:Record.Stem,
            requirements:[Unidoc.Scalar] = [],
            superforms:[Unidoc.Scalar] = [],
            namespace:Unidoc.Scalar,
            culture:Unidoc.Scalar,
            scope:[Unidoc.Scalar],
            file:Unidoc.Scalar? = nil,
            position:SourcePosition? = nil,
            overview:Record.Passage? = nil,
            details:Record.Passage? = nil,
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
            self.file = file

            self.position = position
            self.overview = overview
            self.details = details
            self.group = group
        }
    }
}
extension Record.Master.Decl
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
    var shoot:Record.Shoot
    {
        .init(stem: self.stem, hash: self.flags.route == .hashed ? self.hash : nil)
    }

    @inlinable public
    var hash:FNV24
    {
        .init(hashing: "\(self.symbol)")
    }
}
