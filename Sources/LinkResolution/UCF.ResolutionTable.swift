import InlineArray
import LexicalPaths
import Symbols
import UCF

extension UCF
{
    @frozen public
    struct ResolutionTable<Overload>
    {
        @usableFromInline
        var entries:[ResolutionPath: InlineArray<Overload>]

        @inlinable public
        init()
        {
            self.entries = [:]
        }
    }
}
extension UCF.ResolutionTable:Sendable where Overload:Sendable
{
}
extension UCF.ResolutionTable:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(Never, Never)...) { self.init() }
}
extension UCF.ResolutionTable
{
    @inlinable public
    subscript(namespace:Symbol.Module) -> InlineArray<Overload>
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
