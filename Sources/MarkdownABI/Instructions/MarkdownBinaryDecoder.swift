@frozen public
struct MarkdownBinaryDecoder
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
extension MarkdownBinaryDecoder
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
    func read<Reference>(_:Reference.Type = Reference.self) -> Reference?
        where Reference:FixedWidthInteger
    {
        if  let after:Int = self.bytes.index(self.index,
                offsetBy: MemoryLayout<Reference>.size,
                limitedBy: self.bytes.endIndex)
        {
            defer
            {
                self.index = after
            }
            return self.bytes.withUnsafeBytes
            {
                .init(littleEndian: $0.loadUnaligned(
                    fromByteOffset: self.index,
                    as: Reference.self))
            }
        }
        else
        {
            return nil
        }
    }
    @inlinable internal mutating
    func read<Instruction>(as _:Instruction.Type = Instruction.self) -> Instruction?
        where Instruction:RawRepresentable<UInt8>
    {
        self.read().flatMap(Instruction.init(rawValue:))
    }
}
extension MarkdownBinaryDecoder:IteratorProtocol
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

        switch MarkdownBytecode.Marker.init(rawValue: byte)
        {
        case .push?:
            if  let instruction:MarkdownBytecode.Context = self.read()
            {
                return .push(instruction)
            }
        
        case .pop?:
            return .pop
        
        case .attribute?:
            if  let attribute:MarkdownBytecode.Attribute = self.read()
            {
                return .attribute(attribute)
            }
        
        case .attribute8?:
            if  let attribute:MarkdownBytecode.Attribute = self.read(),
                let reference:UInt8 = self.read()
            {
                return .attribute(attribute, .init(reference))
            }
        
        case .attribute16?:
            if  let attribute:MarkdownBytecode.Attribute = self.read(),
                let reference:UInt16 = self.read()
            {
                return .attribute(attribute, .init(reference))
            }
        
        case .attribute32?:
            if  let attribute:MarkdownBytecode.Attribute = self.read(),
                let reference:UInt32 = self.read()
            {
                return .attribute(attribute, reference)
            }
        
        case .emit?:
            if  let instruction:MarkdownBytecode.Emission = self.read()
            {
                return .emit(instruction)
            }
        
        case .uint8?:
            if  let reference:UInt8 = self.read()
            {
                return .load(.init(reference))
            }

        case .uint16?:
            if  let reference:UInt16 = self.read()
            {
                return .load(.init(reference))
            }
        
        case .uint32?:
            if  let reference:UInt32 = self.read()
            {
                return .load(reference)
            }
        
        case nil:
            //  reserved byte
            break
        }

        return .invalid
    }
}
