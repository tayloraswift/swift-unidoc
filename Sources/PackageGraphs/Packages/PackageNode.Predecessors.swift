import Symbols

extension PackageNode
{
    /// A transparent wrapper around an array of `any Identifiable<Symbol.Package>` that yields
    /// the package identifiers as a ``RandomAccessCollection``.
    @frozen public
    struct Predecessors
    {
        @usableFromInline internal
        let base:[any Identifiable<Symbol.Package>]

        @inlinable internal
        init(_ base:[any Identifiable<Symbol.Package>])
        {
            self.base = base
        }
    }
}
extension PackageNode.Predecessors:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { self.base.startIndex }

    @inlinable public
    var endIndex:Int { self.base.endIndex }

    @inlinable public
    subscript(position:Int) -> Symbol.Package
    {
        self.base[position].id
    }
}
