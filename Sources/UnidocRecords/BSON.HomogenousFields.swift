import BSON

extension BSON {
    /// A helper type for encoding and decoding BSON documents where all fields are of the same
    /// type. It is the programmer’s responsibility to ensure that the keys are unique, as this
    /// may cause documents to fail validation when inserted into a MongoDB collection.
    ///
    /// To defend against SQL injection, the `Key` type should never be allowed to contain null
    /// bytes.
    @frozen public struct HomogenousFields<Key, Value> where Key: Keyspace {
        public let ordered: [(key: Key, value: Value)]

        @inlinable public init(ordered: [(key: Key, value: Value)]) {
            self.ordered = ordered
        }
    }
}
extension BSON.HomogenousFields: Equatable where Key: Equatable, Value: Equatable {
    @inlinable public static func == (a: Self, b: Self) -> Bool {
        a.ordered.elementsEqual(b.ordered) { $0 == $1 }
    }
}
extension BSON.HomogenousFields: Sendable where Value: Sendable {
}
extension BSON.HomogenousFields: ExpressibleByDictionaryLiteral {
    @inlinable public init(dictionaryLiteral: (Key, Value)...) {
        self.init(ordered: dictionaryLiteral)
    }
}
extension BSON.HomogenousFields: BSONDecodable,
    BSONKeyspaceDecodable where Value: BSONDecodable {
    @inlinable public init(bson: consuming BSON.KeyspaceDecoder<Key>) throws {
        var ordered: [(key: Key, value: Value)] = []
        while let field: BSON.FieldDecoder<Key> = try bson[+] {
            ordered.append((field.key, try field.decode(to: Value.self)))
        }
        self.init(ordered: ordered)
    }
}
extension BSON.HomogenousFields: BSONEncodable,
    BSONDocumentEncodable where Value: BSONEncodable {
    @inlinable public func encode(to bson: inout BSON.DocumentEncoder<Key>) {
        for (key, value): (Key, Value) in self.ordered {
            bson[key] = value
        }
    }
}
