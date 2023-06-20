import FNV1
import LexicalPaths
import ModuleGraphs
import Symbols
import UnidocRouting

struct StaticRouter
{
    private(set)
    var hashes:[FNV24: Group<Int32>]
    private(set)
    var paths:[StaticPath: Group<Int32>]

    init()
    {
        self.paths = [:]
        self.hashes = [:]
    }
}
extension StaticRouter
{
    subscript(hash:FNV24) -> Group<Int32>
    {
        _read
        {
            yield  self.hashes[hash, default: []]
        }
        _modify
        {
            yield &self.hashes[hash, default: []]
        }
    }
}
extension StaticRouter
{
    subscript(namespace:ModuleIdentifier,
        path:UnqualifiedPath,
        phylum:ScalarPhylum) -> Group<Int32>
    {
        _read
        {
            yield  self.paths[.declaration(namespace, path, phylum), default: []]
        }
        _modify
        {
            yield &self.paths[.declaration(namespace, path, phylum), default: []]
        }
    }
    subscript(namespace:ModuleIdentifier, name:String) -> Group<Int32>
    {
        _read
        {
            yield  self.paths[.standalone(namespace, name), default: []]
        }
        _modify
        {
            yield &self.paths[.standalone(namespace, name), default: []]
        }
    }
}
