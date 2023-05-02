@frozen public
struct MarkdownBytecode:Equatable, Sendable
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
    @inlinable public
    init(with encode:(inout MarkdownBinaryEncoder) throws -> ()) rethrows
    {
        var encoder:MarkdownBinaryEncoder = .init()
        try encode(&encoder)
        self = encoder.bytecode
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
    func write(reference:UInt32)
    {
        if      let uint8:UInt8 = .init(exactly: reference)
        {
            self.write(marker: .uint8)
            self.bytes.append(uint8)
        }
        else if let uint16:UInt16 = .init(exactly: reference)
        {
            self.write(marker: .uint16)
            withUnsafeBytes(of: uint16.littleEndian)
            {
                self.bytes.append(contentsOf: $0)
            }
        }
        else
        {
            self.write(marker: .uint32)
            withUnsafeBytes(of: reference.littleEndian)
            {
                self.bytes.append(contentsOf: $0)
            }
        }
    }
    @inlinable internal mutating
    func write(_ attribute:Attribute, reference:UInt32)
    {
        if      let uint8:UInt8 = .init(exactly: reference)
        {
            self.write(marker: .attribute8)
            self.bytes.append(attribute.rawValue)
            self.bytes.append(uint8)
        }
        else if let uint16:UInt16 = .init(exactly: reference)
        {
            self.write(marker: .attribute16)
            self.bytes.append(attribute.rawValue)

            withUnsafeBytes(of: uint16.littleEndian)
            {
                self.bytes.append(contentsOf: $0)
            }
        }
        else
        {
            self.write(marker: .attribute32)
            self.bytes.append(attribute.rawValue)

            withUnsafeBytes(of: reference.littleEndian)
            {
                self.bytes.append(contentsOf: $0)
            }
        }
    }
    @inlinable internal mutating
    func write(_ instruction:Attribute)
    {
        self.write(marker: .attribute)
        self.bytes.append(instruction.rawValue)
    }
    @inlinable internal mutating
    func write(_ instruction:Context)
    {
        self.write(marker: .push)
        self.bytes.append(instruction.rawValue)
    }
    @inlinable internal mutating
    func write(_ instruction:Emission)
    {
        self.write(marker: .emit)
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
    func makeIterator() -> MarkdownBinaryDecoder
    {
        .init(bytes: self.bytes)
    }
}
