import BSON
import Signatures

extension GenericParameter: BSONStringEncodable {
    /// The BSON ABI for generic parameters is just a UTF-8 string containing
    /// the name of the parameter, prefixed with its depth in decimal notation.
    ///
    /// For example, if ``name`` is `Element` and ``depth`` is 15, then the ABI
    /// represents it as a string `"15Element"`.
    public var description: String {
        "\(self.depth)\(self.name)"
    }
}
extension GenericParameter: BSONStringDecodable {
    @inlinable public init(bson: BSON.UTF8View<ArraySlice<UInt8>>) throws {
        let prefix: ArraySlice<UInt8> = bson.bytes.prefix {
            0x30 ... 0x39 ~= $0
        }

        let depth: String = .init(decoding: prefix, as: Unicode.ASCII.self)

        guard let depth: UInt = .init(depth) else {
            throw DepthOverflowError.init(expression: depth)
        }

        self.init(
            name: .init(
                decoding: bson.bytes.suffix(from: prefix.endIndex),
                as: Unicode.UTF8.self
            ),
            depth: depth
        )
    }
}
