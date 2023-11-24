import FNV1
import LexicalPaths
import Symbols
import Unidoc

extension StaticLinker
{
    /// A type responsible for detecting URL path collisions between routes in the
    /// same symbol graph.
    struct Router
    {
        private(set)
        var paths:[Route: InlineDictionary<FNV24?, InlineArray<Int32>>]

        init()
        {
            self.paths = [:]
        }
    }
}
extension StaticLinker.Router
{
    subscript(namespace:Symbol.Module,
        path:UnqualifiedPath,
        phylum:Unidoc.Decl) -> InlineDictionary<FNV24?, InlineArray<Int32>>
    {
        _read
        {
            yield  self.paths[.decl(namespace, path, phylum), default: [:]]
        }
        _modify
        {
            yield &self.paths[.decl(namespace, path, phylum), default: [:]]
        }
    }
    subscript(namespace:Symbol.Module,
        name:String) -> InlineDictionary<FNV24?, InlineArray<Int32>>
    {
        _read
        {
            yield  self.paths[.article(namespace, name), default: [:]]
        }
        _modify
        {
            yield &self.paths[.article(namespace, name), default: [:]]
        }
    }
}
