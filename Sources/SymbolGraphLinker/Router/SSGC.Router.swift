import FNV1
import InlineArray
import InlineDictionary
import LexicalPaths
import Symbols
import Unidoc

extension SSGC {
    /// A type responsible for detecting URL path collisions between routes in the
    /// same symbol graph.
    struct Router<Hash, Vertex> where Hash: Hashable {
        private(set) var paths: [Route: InlineDictionary<Hash, InlineArray<Vertex>>]

        init() {
            self.paths = [:]
        }
    }
}
extension SSGC.Router {
    subscript(
        namespace: Symbol.Module,
        path: UnqualifiedPath,
        phylum: Phylum.Decl
    ) -> InlineDictionary<Hash, InlineArray<Vertex>> {
        _read {
            yield  self.paths[.decl(namespace, path, phylum), default: [:]]
        }
        _modify {
            yield &self.paths[.decl(namespace, path, phylum), default: [:]]
        }
    }
    subscript(route: SSGC.Route) -> InlineDictionary<Hash, InlineArray<Vertex>> {
        _read {
            yield  self.paths[route, default: [:]]
        }
        _modify {
            yield &self.paths[route, default: [:]]
        }
    }
}
