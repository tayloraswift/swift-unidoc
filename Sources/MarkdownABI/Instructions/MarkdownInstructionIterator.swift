@frozen public
struct MarkdownInstructionIterator
{
    @usableFromInline
    let bytes:[UInt8]
    @usableFromInline
    var index:Int

    @inlinable internal
    init(bytes:[UInt8])
    {
        self.bytes = bytes
        self.index = bytes.startIndex
    }
}
extension MarkdownInstructionIterator
{
    @inlinable internal mutating
    func read() -> UInt8?
    {
        guard self.index < self.bytes.endIndex
        else
        {
            return nil
        }
        defer
        {
            self.bytes.formIndex(after: &self.index)
        }
        return self.bytes[self.index]
    }
    @inlinable internal mutating
    func read<Instruction>(as _:Instruction.Type = Instruction.self) -> Instruction?
        where Instruction:MarkdownBytecodeInstruction
    {
        self.read().flatMap(Instruction.init(rawValue:))
    }
}
extension MarkdownInstructionIterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> MarkdownInstruction?
    {
        guard let byte:UInt8 = self.read()
        else
        {
            return nil
        }
        switch byte
        {
        case 0x00 ... 0xBF, 0xC2 ... 0xF4:
            return .utf8(byte)
        
        default:
            break
        }

        let marker:MarkdownBytecode.Marker = .init(byte)
        switch marker
        {
        case .attribute:
            if  let attribute:MarkdownBytecode.Attribute = self.read()
            {
                return .attribute(attribute)
            }
        
        case .emit:
            if  let instruction:MarkdownBytecode.Emission = self.read()
            {
                return .emit(instruction)
            }
        
        case .fold:
            return .fold
        
        case .push:
            if  let instruction:MarkdownBytecode.Context = self.read()
            {
                return .push(instruction)
            }
        
        case .pop:
            return .pop
        
        case .reference:
            if  let after:Int = self.bytes.index(self.index, offsetBy: 4,
                    limitedBy: self.bytes.endIndex)
            {
                defer
                {
                    self.index = after
                }
                let reference:MarkdownBinary.Reference = self.bytes.withUnsafeBytes
                {
                    .init(rawValue: $0.loadUnaligned(
                        fromByteOffset: self.index,
                        as: UInt32.self))
                }
                return .reference(reference.id)
            }
        
        case .reserved:
            break
        }

        return .invalid
    }
}
