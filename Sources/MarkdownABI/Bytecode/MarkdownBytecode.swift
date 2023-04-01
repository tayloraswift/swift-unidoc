@frozen public
struct MarkdownBytecode
{
    public
    var bytes:[UInt8]

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.bytes = bytes
    }
}
extension MarkdownBytecode
{
    @inlinable internal mutating
    func write(marker:Marker)
    {
        self.bytes.append(marker.rawValue)
    }

    @inlinable public mutating
    func write(instruction:MarkdownInstruction.Pop)
    {
        self.write(marker: MarkdownInstruction.Pop.marker)
    }
    @inlinable public mutating
    func write<Instruction>(instruction:Instruction)
        where Instruction:MarkdownInstructionType<UInt8>
    {
        self.write(marker: Instruction.marker)
        self.bytes.append(instruction.rawValue)
    }
    @inlinable public mutating
    func write(instruction:MarkdownInstruction.Reference)
    {
        self.write(marker: MarkdownInstruction.Reference.marker)

        withUnsafeBytes(of: instruction.rawValue)
        {
            self.bytes.append(contentsOf: $0)
        }
    }

    @inlinable public mutating
    func write(text:some StringProtocol)
    {
        self.bytes.append(contentsOf: text.utf8)
    }
}
extension MarkdownBytecode:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(bytes: self.bytes)
    }
}
