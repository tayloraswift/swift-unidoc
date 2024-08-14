import InlineArray
import LexicalPaths
import Symbols
import UCF

extension UCF
{
    @frozen public
    struct ResolutionTable<Overload> where Overload:ResolvableOverload
    {
        @usableFromInline
        var entries:[UCF.ResolutionPath: InlineArray<Overload>]
        @usableFromInline
        var modules:[UCF.ResolutionPath: Symbol.Module]

        @inlinable public
        init()
        {
            self.entries = [:]
            self.modules = [:]
        }
    }
}
extension UCF.ResolutionTable:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(Never, Never)...) { self.init() }
}
extension UCF.ResolutionTable
{
    /// Lowercases all paths in the table, merging overloads with the same case-folded path.
    /// Some modules may become **unresolvable** if they have names that differ only in case.
    public
    func caseFolded() -> Self
    {
        var copy:Self = self

        copy.entries.removeAll(keepingCapacity: true)
        copy.modules.removeAll(keepingCapacity: true)

        for (path, overloads):(UCF.ResolutionPath, InlineArray<Overload>) in self.entries
        {
            {
                for overload:Overload in overloads
                {
                    $0.append(overload)
                }
            } (&copy.entries[path.lowercased(), default: .some([])])
        }
        //  We need to sort this one because it can suffer from path collisions, and the
        //  “winning” module would otherwise be non-deterministic.
        for (path, module):(UCF.ResolutionPath, Symbol.Module) in self.modules.sorted(
            by: { $0.value < $1.value })
        {
            copy.modules[path.lowercased()] = module
        }

        return copy
    }
}
extension UCF.ResolutionTable
{
    @inlinable public mutating
    func register(_ module:Symbol.Module)
    {
        self.modules[.init(module)] = module
    }
}
extension UCF.ResolutionTable
{
    @inlinable public
    subscript(namespace:Symbol.Module,
        path:UnqualifiedPath) -> InlineArray<Overload>
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
        last:String) -> InlineArray<Overload>
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
extension UCF.ResolutionTable
{
    func resolve(_ selector:UCF.Selector,
        in scope:UCF.ResolutionScope) -> UCF.Resolution<Overload>
    {
        var search:Search = .init(matching: selector.suffix)

        if  case .relative = selector.base
        {
            let ends:ClosedRange<Int> = scope.path.startIndex ... scope.path.endIndex
            for end:Int in ends.reversed()
            {
                let path:UCF.ResolutionPath = .join(["\(scope.namespace)"]
                    + scope.path.prefix(upTo: end)
                    + selector.path.components)

                if  let list:InlineArray<Overload> = self.entries[path]
                {
                    search.add(list)
                }
                if  let matches:UCF.Resolution<Overload> = search.any()
                {
                    return matches
                }
            }

            for namespace:Symbol.Module in self.modules.values where
                namespace != scope.namespace
            {
                let path:UCF.ResolutionPath = .join(["\(namespace)"] + selector.path.components)
                if  let list:InlineArray<Overload> = self.entries[path]
                {
                    search.add(list)
                }
            }

            if  let matches:UCF.Resolution<Overload> = search.any()
            {
                return matches
            }
        }

        //  If we got this far, assume the first path component is a module name.
        if  selector.path.components.count == 1
        {
            let path:UCF.ResolutionPath = .init(string: selector.path.components[0])
            if  let module:Symbol.Module = self.modules[path]
            {
                return .module(module)
            }
        }

        let path:UCF.ResolutionPath = .join(selector.path.components)
        if  let list:InlineArray<Overload> = self.entries[path]
        {
            search.add(list)
        }

        return search.get()
    }
}
