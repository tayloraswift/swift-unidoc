extension MarkdownBinary
{
    /// An instruction that delegates a document encoding task to some
    /// external encoding implementation.
    @frozen @usableFromInline internal
    struct Reference:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        let id:UInt32

        @inlinable internal
        init(id:UInt32)
        {
            self.id = id
        }
    }
}
extension MarkdownBinary.Reference:Comparable
{
    @inlinable internal static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.id < rhs.id
    }
}
extension MarkdownBinary.Reference:RawRepresentable
{
    /// The little-endian raw value of this reference instruction.
    @inlinable internal
    var rawValue:UInt32
    {
        self.id.littleEndian
    }

    /// Loads a reference instruction from a little-endian raw value.
    @inlinable internal
    init(rawValue:UInt32)
    {
        self.init(id: .init(littleEndian: rawValue))
    }
}
