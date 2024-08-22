import FNV1
import LexicalPaths
import Symbols
import UCF

extension UCF.Overload
{
    @frozen public
    struct Table
    {
        @usableFromInline
        var entries:[UCF.ResolutionPath: Group]

        @inlinable public
        init()
        {
            self.entries = [:]
        }
    }
}
extension UCF.Overload.Table:Sendable where Scalar:Sendable
{
}
extension UCF.Overload.Table
{
    public
    func caseless() -> Self
    {
        var copy:Self = self
            copy.entries.removeAll(keepingCapacity: true)

        for (path, overloads) in self.entries
        {
            copy.entries[.init(string: path.string.lowercased()), default: .some([])].overload(
                with: overloads)
        }

        return copy
    }
}
extension UCF.Overload.Table
{
    @inlinable public
    subscript(namespace:Symbol.Module) -> UCF.Overload<Scalar>.Group
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
        path:UnqualifiedPath) -> UCF.Overload<Scalar>.Group
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
        last:String) -> UCF.Overload<Scalar>.Group
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
extension UCF.Overload.Table
{
    func query(
        qualified path:[String],
        suffix:UCF.Selector.Suffix?) -> UCF.Overload<Scalar>.Group
    {
        guard
        let overloads:UCF.Overload<Scalar>.Group = self.entries[.join(path)]
        else
        {
            return .some([])
        }

        guard
        case .some(let overloads) = overloads,
        let suffix:UCF.Selector.Suffix
        else
        {
            return overloads
        }

        switch suffix
        {
        case .legacy(let filter, nil):
            return .init(filtering: overloads) { filter ~= $0.phylum }

        case .legacy(_, let hash?):
            return .init(filtering: overloads) { hash == $0.hash }

        case .hash(let hash):
            return .init(filtering: overloads) { hash == $0.hash }

        case .filter(let filter):
            return .init(filtering: overloads) { filter ~= $0.phylum }
        }
    }
}
