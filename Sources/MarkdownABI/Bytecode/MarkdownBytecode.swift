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

    @inlinable internal mutating
    func write(reference:MarkdownBinary.Reference)
    {
        self.write(marker: .reference)

        withUnsafeBytes(of: reference.rawValue)
        {
            self.bytes.append(contentsOf: $0)
        }
    }
    @inlinable internal mutating
    func write<Instruction>(instruction:Instruction)
        where Instruction:MarkdownBytecodeInstruction
    {
        self.write(marker: Instruction.marker)
        self.bytes.append(instruction.rawValue)
    }

    @inlinable internal mutating
    func write(text:some StringProtocol)
    {
        self.bytes.append(contentsOf: text.utf8)
    }
}
extension MarkdownBytecode:Sequence
{
    @inlinable public
    func makeIterator() -> MarkdownInstructionIterator
    {
        .init(bytes: self.bytes)
    }
}
