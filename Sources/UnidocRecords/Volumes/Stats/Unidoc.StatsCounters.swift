import BSON

extension Unidoc {
    public protocol StatsCounters: ExpressibleByDictionaryLiteral where Value == Never {
        associatedtype CodingKey: BSON.Keyspace, CaseIterable

        static subscript(key: CodingKey) -> WritableKeyPath<Self, Int> { get }
    }
}
extension Unidoc.StatsCounters {
    @inlinable public var total: Int {
        CodingKey.allCases.reduce(0) { $0 + self[keyPath: Self[$1]] }
    }
}
extension Unidoc.StatsCounters where Self: BSONDocumentEncodable {
    @inlinable public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        for key in CodingKey.allCases {
            let value: Int = self[keyPath: Self[key]]
            if  value != 0 {
                bson[key] = value
            }
        }
    }
}
extension Unidoc.StatsCounters where Self: BSONKeyspaceDecodable {
    @inlinable public init(bson: consuming BSON.KeyspaceDecoder<CodingKey>) throws {
        self = [:]
        while let field: BSON.FieldDecoder<CodingKey> = try bson[+] {
            self[keyPath: Self[field.key]] = try field.decode()
        }
    }
}
