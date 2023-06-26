import Codelinks
import FNV1
import LexicalPaths
import ModuleGraphs
import SymbolGraphs

extension CodelinkResolver
{
    @frozen public
    struct Table
    {
        @usableFromInline internal
        var entries:[CodelinkResolutionPath: Overloads]

        @inlinable public
        init()
        {
            self.entries = [:]
        }
    }
}
extension CodelinkResolver.Table:Sendable where Scalar:Sendable
{
}
extension CodelinkResolver.Table
{
    @inlinable public
    subscript(namespace:ModuleIdentifier,
        path:UnqualifiedPath) -> CodelinkResolver<Scalar>.Overloads
    {
        _read
        {
            yield  self.entries[.join(namespace, path), default: .some([])]
        }
        _modify
        {
            yield &self.entries[.join(namespace, path), default: .some([])]
        }
    }
    @inlinable public
    subscript(namespace:ModuleIdentifier,
        path:UnqualifiedPath,
        last:String) -> CodelinkResolver<Scalar>.Overloads
    {
        _read
        {
            yield  self.entries[.join(namespace, path, last), default: .some([])]
        }
        _modify
        {
            yield &self.entries[.join(namespace, path, last), default: .some([])]
        }
    }
}
extension CodelinkResolver.Table
{
    func query(_ path:[String],
        filter:Codelink.Filter?,
        hash:FNV24?) -> CodelinkResolver<Scalar>.Overloads?
    {
        let overloads:CodelinkResolver<Scalar>.Overloads = self.query(path,
            filter: filter,
            hash: hash)
        if  case .some(let overloads) = overloads, overloads.isEmpty
        {
            return nil
        }
        else
        {
            return overloads
        }
    }
    func query(_ path:[String],
        filter:Codelink.Filter?,
        hash:FNV24?) -> CodelinkResolver<Scalar>.Overloads
    {
        switch (self.entries[.join(path), default: .some([])], hash, filter)
        {
        case (.some(let overloads), let hash?,  _):
            return .init(filtering: overloads) { hash == $0.hash }

        case (.some(let overloads), nil,        let filter?):
            return .init(filtering: overloads) { filter ~= $0.phylum }

        case (      let overloads,  _,          _):
            return overloads
        }
    }
}
