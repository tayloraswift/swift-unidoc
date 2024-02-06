import BSON

extension SymbolGraph
{
    /// A type that can serialize an array of ``SymbolGraph.DeclPlane`` scalars
    /// much more compactly than a native BSON list.
    ///
    /// Empirically, this type reduces symbol graph archive size by around
    /// 3 to 8 percent.
    @frozen @usableFromInline internal
    struct Buffer:Equatable, Sendable
    {
        @usableFromInline internal
        var elements:[Int32]

        @inlinable internal
        init(_ elements:[Int32])
        {
            self.elements = elements
        }
    }
}
extension SymbolGraph.Buffer
{
    @inlinable internal
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
extension SymbolGraph.Buffer:BSONEncodable
{
    @usableFromInline internal
    func encode(to field:inout BSON.FieldEncoder)
    {
        let bson:BSON.BinaryView<[UInt8]> = .init(subtype: .generic, bytes: .init(
            unsafeUninitializedCapacity: self.elements.count * 3)
        {
            for (i, scalar):(Int, Int32) in self.elements.enumerated()
            {
                $0[i * 3 + 0] = UInt8.init(truncatingIfNeeded: scalar)
                $0[i * 3 + 1] = UInt8.init(truncatingIfNeeded: scalar >> 8)
                $0[i * 3 + 2] = UInt8.init(truncatingIfNeeded: scalar >> 16)
            }

            $1 = $0.count
        })

        bson.encode(to: &field)
    }
}
extension SymbolGraph.Buffer:BSONBinaryViewDecodable
{
    @inlinable internal
    init(bson:BSON.BinaryView<ArraySlice<UInt8>>) throws
    {
        self = try bson.bytes.withUnsafeBytes(Self.init(bytes:))
    }

    /// Is there even a measurable benefit from using `UnsafeRawBufferPointer` here?
    @inlinable internal
    init(bytes compact:UnsafeRawBufferPointer) throws
    {
        guard compact.startIndex < compact.endIndex
        else
        {
            self.init([])
            return
        }

        guard case (let count, 0) = compact.count.quotientAndRemainder(dividingBy: 3)
        else
        {
            throw SymbolGraph.BufferError.init()
        }

        self.init(.init(unsafeUninitializedCapacity: count)
        {
            var a:Int = compact.startIndex
            for i:Int in 0 ..< count
            {
                let b:Int = compact.index(after: a)
                let c:Int = compact.index(after: b)
                defer
                {
                    a = compact.index(after: c)
                }

                $0[i] = .decl
                    | Int32.init(compact[a])
                    | Int32.init(compact[b]) << 8
                    | Int32.init(compact[c]) << 16

            }

            $1 = count
        })
    }
}
