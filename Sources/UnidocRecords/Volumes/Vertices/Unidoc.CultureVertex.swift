import FNV1
import MarkdownABI
import SymbolGraphs
import Symbols
import Unidoc
import UnidocAPI

extension Unidoc {
    @frozen public struct CultureVertex: Identifiable, Equatable, Sendable {
        public let id: Unidoc.Scalar

        public let module: SymbolGraph.Module
        public var readme: Unidoc.Scalar?
        public var census: Unidoc.Census

        public var headline: Markdown.Bytecode?
        public var overview: Unidoc.Passage?
        public var details: Unidoc.Passage?
        public var group: Unidoc.Group?

        @inlinable public init(
            id: Unidoc.Scalar,
            module: SymbolGraph.Module,
            readme: Unidoc.Scalar? = nil,
            census: Unidoc.Census = .init(),
            headline: Markdown.Bytecode? = nil,
            overview: Unidoc.Passage? = nil,
            details: Unidoc.Passage? = nil,
            group: Unidoc.Group? = nil
        ) {
            self.id = id

            self.module = module
            self.readme = readme
            self.census = census

            self.headline = headline
            self.overview = overview
            self.details = details
            self.group = group
        }
    }
}
extension Unidoc.CultureVertex: Unidoc.PrincipalVertex {
    @inlinable public var stem: Unidoc.Stem { .module(self.module.id) }

    @inlinable public var hash: FNV24.Extended { .module(self.module.id) }

    /// I AM THE CULTURE
    @inlinable public var bias: Unidoc.Bias { .culture(self.id) }

    @inlinable public var decl: Phylum.DeclFlags? { nil }
}
