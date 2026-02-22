import BSON

/// A symbol graph archive is just a ``SymbolGraph`` with ``SymbolGraphMetadata``.
///
/// We know that “Object” is a terrible name, but we can’t think of anything better.
@frozen public struct SymbolGraphObject<ID> {
    public var metadata: SymbolGraphMetadata
    public var graph: SymbolGraph
    public var id: ID

    @inlinable public init(metadata: SymbolGraphMetadata, graph: SymbolGraph, id: ID) {
        self.metadata = metadata
        self.graph = graph
        self.id = id
    }
}
extension SymbolGraphObject<Void> {
    @inlinable public init(metadata: SymbolGraphMetadata, graph: SymbolGraph) {
        self.init(metadata: metadata, graph: graph, id: ())
    }
}
extension SymbolGraphObject: Identifiable where ID: Hashable {
}
extension SymbolGraphObject: Equatable where ID: Equatable {
}
extension SymbolGraphObject: Sendable where ID: Sendable {
}
extension SymbolGraphObject<Void> {
    public enum CodingKey: String, Sendable {
        case metadata
        case graph
    }
}
extension SymbolGraphObject<Void>: BSONDocumentEncodable, BSONEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.metadata] = self.metadata
        bson[.graph] = self.graph
    }
}
extension SymbolGraphObject<Void>: BSONDocumentDecodable, BSONDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(metadata: try bson[.metadata].decode(), graph: try bson[.graph].decode())
    }

    public init(buffer: ArraySlice<UInt8>) throws {
        try self.init(bson: BSON.Document.init(bytes: buffer))
    }

    public init(buffer: [UInt8]) throws {
        try self.init(buffer: buffer[...])
    }
}
