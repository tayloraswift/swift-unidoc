extension MarkdownInstruction
{
    /// An instruction that delegates a document encoding task to some
    /// external encoding implementation.
    @frozen public
    struct Reference:Equatable, Hashable, Sendable
    {
        public
        let id:UInt32

        @inlinable public
        init(id:UInt32)
        {
            self.id = id
        }
    }
}
extension MarkdownInstruction.Reference:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.id < rhs.id
    }
}
extension MarkdownInstruction.Reference:RawRepresentable
{
    /// The little-endian raw value of this reference instruction.
    @inlinable public
    var rawValue:UInt32
    {
        self.id.littleEndian
    }

    /// Loads a reference instruction from a little-endian raw value.
    @inlinable public
    init(rawValue:UInt32)
    {
        self.init(id: .init(littleEndian: rawValue))
    }
}
extension MarkdownInstruction.Reference:MarkdownInstructionType
{
    @inlinable public static
    var marker:MarkdownBytecode.Marker { .reference }
}
