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
    func read<Reference>(_:Reference.Type) -> Int?
        where Reference:FixedWidthInteger & UnsignedInteger
    {
        if  let after:Int = self.bytes.index(self.index,
                offsetBy: MemoryLayout<Reference>.size,
                limitedBy: self.bytes.endIndex)
        {
            defer
            {
                self.index = after
            }
            let reference:Reference = self.bytes.withUnsafeBytes
            {
                .init(littleEndian: $0.loadUnaligned(
                    fromByteOffset: self.index,
                    as: Reference.self))
            }
            if  let uint:UInt = .init(exactly: reference)
            {
                return .init(bitPattern: uint)
            }
            else
            {
                fatalError("Cannot decode 64-bit markdown references on a 32-bit platform!")
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
                let reference:Int = self.read(UInt8.self)
            {
                return .attribute(attribute, reference)
            }

        case .attribute16?:
            if  let attribute:MarkdownBytecode.Attribute = self.read(),
                let reference:Int = self.read(UInt16.self)
            {
                return .attribute(attribute, reference)
            }

        case .attribute32?:
            if  let attribute:MarkdownBytecode.Attribute = self.read(),
                let reference:Int = self.read(UInt32.self)
            {
                return .attribute(attribute, reference)
            }

        case .attribute64?:
            if  let attribute:MarkdownBytecode.Attribute = self.read(),
                let reference:Int = self.read(UInt64.self)
            {
                return .attribute(attribute, reference)
            }

        case .emit?:
            if  let instruction:MarkdownBytecode.Emission = self.read()
            {
                return .emit(instruction)
            }

        case .uint8?:
            if  let reference:Int = self.read(UInt8.self)
            {
                return .load(reference)
            }

        case .uint16?:
            if  let reference:Int = self.read(UInt16.self)
            {
                return .load(reference)
            }

        case .uint32?:
            if  let reference:Int = self.read(UInt32.self)
            {
                return .load(reference)
            }

        case .uint64?:
            if  let reference:Int = self.read(UInt64.self)
            {
                return .load(reference)
            }

        case ._reserved?, nil:
            //  reserved byte
            break
        }

        return .invalid
    }
}
