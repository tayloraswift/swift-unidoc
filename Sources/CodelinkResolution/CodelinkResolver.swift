import Codelinks
import FNV1
import LexicalPaths
import ModuleGraphs
import SymbolGraphs

@frozen public
struct CodelinkResolver<Address> where Address:Hashable
{
    @usableFromInline internal
    var entries:[CodelinkResolutionPath: Overloads]

    @inlinable public
    init()
    {
        self.entries = [:]
    }
}
extension CodelinkResolver
{
    @inlinable public
    subscript(namespace:ModuleIdentifier, path:UnqualifiedPath) -> Overloads
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
    subscript(namespace:ModuleIdentifier, path:UnqualifiedPath, last:String) -> Overloads
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
extension CodelinkResolver
{
    @_specialize(where Address == Int32)
    @_specialize(where Address == GlobalAddress)
    public
    func query(ascending scope:[String], link:Codelink) -> Overloads
    {
        for index:Int in (scope.startIndex ... scope.endIndex).reversed()
        {
            let prefix:ArraySlice = scope.prefix(upTo: index)
            let path:[String]

            switch (prefix, link.scope)
            {
            case ([], nil):
                path = .init                              (link.path.components)

            case ([], let scope?):
                path = .init          (scope.components) + link.path.components

            case (_ , let scope?):
                path = .init(prefix) + scope.components  + link.path.components

            case (_ , nil):
                path = .init(prefix) +                     link.path.components
            }

            switch self.query(path, filter: link.filter, hash: link.hash)
            {
            case .one(let overload):
                return .one(overload)

            case .some(let overloads):
                if !overloads.isEmpty
                {
                    return .some(overloads)
                }
            }
        }
        return .some([])
    }
    private
    func query(_ path:[String], filter:Codelink.Filter?, hash:FNV24?) -> Overloads
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
