import InlineArray
import LexicalPaths
import Symbols
import UCF

extension UCF
{
    @frozen public
    struct ResolutionTable<Overload> where Overload:ResolvableOverload
    {
        public
        var modules:[Symbol.Module]
        @usableFromInline
        var entries:[UCF.ResolutionPath: InlineArray<Overload>]

        @inlinable public
        init()
        {
            self.modules = []
            self.entries = [:]
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

            for namespace:Symbol.Module in self.modules.reversed() where
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
            let last:Symbol.Module = .init(selector.path.components[0])
            if  self.modules.contains(last)
            {
                return .module(last)
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
