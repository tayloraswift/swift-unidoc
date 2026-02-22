extension Markdown {
    @frozen public struct Bytecode: Equatable, Sendable {
        public var bytes: [UInt8]

        @inlinable public init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }
}
extension Markdown.Bytecode {
    @inlinable public var isEmpty: Bool {
        self.bytes.isEmpty
    }
}
extension Markdown.Bytecode {
    @inlinable public init(with encode: (inout Markdown.BinaryEncoder) throws -> ()) rethrows {
        var encoder: Markdown.BinaryEncoder = .init()
        try encode(&encoder)
        self = encoder.bytecode
    }
}
extension Markdown.Bytecode: ExpressibleByArrayLiteral {
    @inlinable public init(arrayLiteral: UInt8...) {
        self.init(bytes: arrayLiteral)
    }
}
extension Markdown.Bytecode {
    @inlinable internal mutating func write(marker: Marker) {
        self.bytes.append(marker.rawValue)
    }

    @inlinable internal mutating func write(reference: Int) {
        let reference: UInt = .init(bitPattern: reference)

        if      let uint8: UInt8 = .init(exactly: reference) {
            self.write(marker: .uint8)
            self.bytes.append(uint8)
        } else if let uint16: UInt16 = .init(exactly: reference) {
            self.write(marker: .uint16)
            withUnsafeBytes(of: uint16.littleEndian) {
                self.bytes.append(contentsOf: $0)
            }
        } else if let uint32: UInt32 = .init(exactly: reference) {
            self.write(marker: .uint32)
            withUnsafeBytes(of: uint32.littleEndian) {
                self.bytes.append(contentsOf: $0)
            }
        } else if UInt.bitWidth == 64 {
            self.write(marker: .uint64)
            withUnsafeBytes(of: reference.littleEndian) {
                self.bytes.append(contentsOf: $0)
            }
        } else {
            fatalError("Unsupported architecture!")
        }
    }
    @inlinable internal mutating func write(_ attribute: Attribute, reference: Int) {
        let reference: UInt = .init(bitPattern: reference)

        if      let uint8: UInt8 = .init(exactly: reference) {
            self.write(marker: .attribute8)
            self.bytes.append(attribute.rawValue)
            self.bytes.append(uint8)
        } else if let uint16: UInt16 = .init(exactly: reference) {
            self.write(marker: .attribute16)
            self.bytes.append(attribute.rawValue)

            withUnsafeBytes(of: uint16.littleEndian) {
                self.bytes.append(contentsOf: $0)
            }
        } else if let uint32: UInt32 = .init(exactly: reference) {
            self.write(marker: .attribute32)
            self.bytes.append(attribute.rawValue)

            withUnsafeBytes(of: uint32.littleEndian) {
                self.bytes.append(contentsOf: $0)
            }
        } else if UInt.bitWidth == 64 {
            self.write(marker: .attribute64)
            self.bytes.append(attribute.rawValue)

            withUnsafeBytes(of: reference.littleEndian) {
                self.bytes.append(contentsOf: $0)
            }
        } else {
            fatalError("Unsupported architecture!")
        }
    }
    @inlinable internal mutating func write(_ instruction: Attribute) {
        self.write(marker: .attribute)
        self.bytes.append(instruction.rawValue)
    }
    @inlinable internal mutating func write(_ instruction: Context) {
        self.write(marker: .push)
        self.bytes.append(instruction.rawValue)
    }
    @inlinable internal mutating func write(_ instruction: Emission) {
        self.write(marker: .emit)
        self.bytes.append(instruction.rawValue)
    }

    @inlinable internal mutating func write(text: some StringProtocol) {
        self.write(utf8: text.utf8)
    }
    @inlinable internal mutating func write(utf8: some Sequence<UInt8>) {
        self.bytes.append(contentsOf: utf8)
    }
}
extension Markdown.Bytecode: Sequence {
    @inlinable public func makeIterator() -> Markdown.BinaryDecoder {
        .init(bytes: self.bytes)
    }
}
