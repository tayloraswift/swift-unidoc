import Codelinks
import FNV1
import LexicalPaths
import Symbols

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
    subscript(namespace:Symbol.Module) -> CodelinkResolver<Scalar>.Overloads
    {
        _read
        {
            yield  self.entries[.init(namespace), default: .some([])]
        }
        _modify
        {
            yield &self.entries[.init(namespace), default: .some([])]
        }
    }
    @inlinable public
    subscript(namespace:Symbol.Module,
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
    subscript(namespace:Symbol.Module,
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
    func query(
        qualified path:[String],
        suffix:Codelink.Suffix?) -> CodelinkResolver<Scalar>.Overloads
    {
        guard
        let overloads:CodelinkResolver<Scalar>.Overloads = self.entries[.join(path)]
        else
        {
            return .some([])
        }

        guard
        case .some(let overloads) = overloads,
        let suffix:Codelink.Suffix
        else
        {
            return overloads
        }

        switch suffix
        {
        case .legacy(let suffix):
            guard
            let hash:FNV24 = suffix.hash
            else
            {
                return .init(filtering: overloads) { suffix.filter ~= $0.phylum }
            }

            return .init(filtering: overloads) { hash == $0.hash }

        case .hash(let hash):
            return .init(filtering: overloads) { hash == $0.hash }

        case .filter(let filter):
            return .init(filtering: overloads) { filter ~= $0.phylum }
        }
    }
}
