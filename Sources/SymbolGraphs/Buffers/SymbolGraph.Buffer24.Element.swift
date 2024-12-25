import BSON

extension SymbolGraph.Buffer24
{
    @frozen @usableFromInline
    struct Element
    {
        @usableFromInline
        let int32:Int32

        @inlinable
        init(int32:Int32)
        {
            self.int32 = int32
        }
    }
}
extension SymbolGraph.Buffer24.Element:BSON.BinaryPackable
{
    @usableFromInline
    typealias Storage = (UInt8, UInt8, UInt8)

    @inlinable
    static func get(_ storage:Storage) -> Self
    {
        self.init(int32: .decl
            | Int32.init(storage.0)
            | Int32.init(storage.1) << 8
            | Int32.init(storage.2) << 16)
    }

    @inlinable
    consuming func set() -> Storage
    {
        (
            UInt8.init(truncatingIfNeeded: self.int32),
            UInt8.init(truncatingIfNeeded: self.int32 >> 8),
            UInt8.init(truncatingIfNeeded: self.int32 >> 16)
        )
    }
}
