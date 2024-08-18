import Availability
import LexicalPaths
import Signatures
import Sources
import SymbolGraphParts
import Symbols

extension SSGC
{
    /// A scalar is the smallest “unit” a symbol can be broken down into.
    @frozen public
    struct Decl:Identifiable, Equatable, Sendable
    {
        public
        let id:Symbol.Decl

        public
        let signature:Signature<Symbol.Decl>
        public
        let location:SourceLocation<Symbol.File>?

        public
        let phylum:Phylum.Decl
        public
        let path:UnqualifiedPath

        /// Protocol requirements.
        public internal(set)
        var requirements:Set<Symbol.Decl>

        /// Enumeration cases.
        public internal(set)
        var inhabitants:Set<Symbol.Decl>

        /// The scalars that this scalar implements, overrides, or inherits
        /// from. Superforms are intrinsic but there can be more than one
        /// per scalar.
        ///
        /// Only protocols can inherit from other protocols. (All other
        /// phyla can only conform to protocols.) Any class can inherit
        /// from another class.
        ///
        /// The compiler does not check for inheritance cycles.
        public internal(set)
        var superforms:Set<Symbol.Decl>

        /// Scalars that potentially have documentation that is relevant, but less specific
        /// to this scalar. Only one will be ultimately used, but the others are kept for
        /// de-duplication purposes.
        public internal(set)
        var origins:Set<Symbol.Decl>
        public internal(set)
        var kinks:Phylum.Decl.Kinks

        public
        var comment:DocumentationComment?


        init(id:Symbol.Decl,
            signature:Signature<Symbol.Decl>,
            location:SourceLocation<Symbol.File>?,
            phylum:Phylum.Decl,
            path:UnqualifiedPath,
            kinks:Phylum.Decl.Kinks,
            comment:DocumentationComment?)
        {
            self.id = id

            self.signature = signature
            self.location = location
            self.phylum = phylum
            self.path = path

            self.requirements = []
            self.inhabitants = []
            self.superforms = []
            self.origins = []

            self.kinks = kinks
            self.comment = comment
        }
    }
}
