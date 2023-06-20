import FNV1
import LexicalPaths
import ModuleGraphs
import Symbols
import UnidocRouting

struct StaticRouter
{
    private(set)
    var paths:[StaticPath: InlineDictionary<FNV24?, InlineArray<Int32>>]

    init()
    {
        self.paths = [:]
    }
}
extension StaticRouter
{
    subscript(namespace:ModuleIdentifier,
        path:UnqualifiedPath,
        phylum:ScalarPhylum) -> InlineDictionary<FNV24?, InlineArray<Int32>>
    {
        _read
        {
            yield  self.paths[.declaration(namespace, path, phylum), default: [:]]
        }
        _modify
        {
            yield &self.paths[.declaration(namespace, path, phylum), default: [:]]
        }
    }
    subscript(namespace:ModuleIdentifier,
        name:String) -> InlineDictionary<FNV24?, InlineArray<Int32>>
    {
        _read
        {
            yield  self.paths[.standalone(namespace, name), default: [:]]
        }
        _modify
        {
            yield &self.paths[.standalone(namespace, name), default: [:]]
        }
    }
}
