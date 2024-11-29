import BSON

extension SymbolGraph
{
    /// A type that can serialize an array of ``SymbolGraph.DeclPlane`` scalars
    /// much more compactly than a native BSON list.
    ///
    /// Empirically, this type reduces symbol graph archive size by around
    /// 3 to 8 percent.
    @frozen @usableFromInline
    struct Buffer24:Equatable, Sendable
    {
        @usableFromInline
        var elements:[Int32]

        @inlinable
        init(_ elements:[Int32])
        {
            self.elements = elements
        }
    }
}
extension SymbolGraph.Buffer24
{
    @inlinable
    init?(elidingEmpty elements:[Int32])
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

extension SymbolGraph.Buffer24:RandomAccessCollection
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
            let scalar:Int32 = self.elements[position]
            return
                (
                    UInt8.init(truncatingIfNeeded: scalar),
                    UInt8.init(truncatingIfNeeded: scalar >> 8),
                    UInt8.init(truncatingIfNeeded: scalar >> 16)
                )
        }
    }
}
extension SymbolGraph.Buffer24:BSONArrayEncodable
{
}
extension SymbolGraph.Buffer24:BSONArrayDecodable
{
    @usableFromInline
    typealias CodingElement = (UInt8, UInt8, UInt8)

    @inlinable
    init(from bson:borrowing BSON.BinaryBuffer<CodingElement>) throws
    {
        self.init(bson.map
        {
            .decl
                | Int32.init($0)
                | Int32.init($1) << 8
                | Int32.init($2) << 16
        })
    }
}
