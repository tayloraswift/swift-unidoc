import BSON

extension SymbolGraph
{
    /// A type that can serialize an array of ``Int`` indices much more compactly than a native
    /// BSON list. This must only be used for arrays of indices that are known to be small,
    /// like modules. Specifically, indices must be less than 2^16.
    @frozen @usableFromInline
    struct Buffer16:Equatable, Sendable
    {
        @usableFromInline
        var elements:[Int]

        @inlinable internal
        init(_ elements:[Int])
        {
            self.elements = elements
        }
    }
}
extension SymbolGraph.Buffer16
{
    @inlinable internal
    init?(elidingEmpty elements:[Int])
    {
        if  elements.isEmpty
        {
            return nil
        }
        else
        {
            self.init(elements)
        }
    }
}

extension SymbolGraph.Buffer16:RandomAccessCollection
{
    @inlinable
    var startIndex:Int { self.elements.startIndex }

    @inlinable
    var endIndex:Int { self.elements.endIndex }

    @inlinable
    subscript(position:Int) -> CodingElement
    {
        get
        {
            let scalar:Int = self.elements[position]
            return
                (
                    UInt8.init(truncatingIfNeeded: scalar),
                    UInt8.init(truncatingIfNeeded: scalar >> 8)
                )
        }
    }
}
extension SymbolGraph.Buffer16:BSONArrayEncodable
{
}
extension SymbolGraph.Buffer16:BSONArrayDecodable
{
    @usableFromInline
    typealias CodingElement = (UInt8, UInt8)

    @inlinable
    init(from bson:borrowing BSON.BinaryArray<CodingElement>) throws
    {
        self.init(bson.map { Int.init($0) | Int.init($1) << 8 })
    }
}
