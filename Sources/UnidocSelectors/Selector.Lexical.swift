import FNV1
import Symbols
import UnidocRecords

extension Selector
{
    @frozen public
    struct Lexical:Equatable, Hashable, Sendable
    {
        public
        var stem:Record.Stem
        public
        var hash:FNV24?

        @inlinable internal
        init(stem:Record.Stem, hash:FNV24?)
        {
            self.stem = stem
            self.hash = hash
        }
    }
}
extension Selector.Lexical
{
    public
    init(stem path:__shared ArraySlice<String>, hash:__owned FNV24? = nil)
    {
        self.init(stem: .init(path: path), hash: hash)
    }
}
extension Selector.Lexical
{
    @inlinable public static
    var trunk:Self { .init(stem: "", hash: nil) }
}
