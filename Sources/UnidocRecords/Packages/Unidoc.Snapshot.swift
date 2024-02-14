import BSON
import SemanticVersions
import SymbolGraphs
import Symbols
import Unidoc

extension Unidoc
{
    @frozen public
    struct Snapshot:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Edition

        public
        var metadata:SymbolGraphMetadata
        public
        var inline:SymbolGraph?

        /// Only present for standard library snapshots. This is used to automatically load
        /// the latest version of the standard library without querying git tags.
        public
        var swift:PatchVersion?
        public
        var pins:[Unidoc.Edition?]

        public
        var link:LinkState?

        public
        var type:GraphType
        public
        var size:Int64

        @inlinable internal
        init(id:Unidoc.Edition,
            metadata:SymbolGraphMetadata,
            inline:SymbolGraph?,
            swift:PatchVersion?,
            pins:[Unidoc.Edition?],
            link:LinkState?,
            type:GraphType,
            size:Int64)
        {
            self.id = id
            self.metadata = metadata
            self.inline = inline
            self.swift = swift
            self.pins = pins

            self.link = link
            self.type = type
            self.size = size
        }
    }
}
extension Unidoc.Snapshot
{
    @inlinable public
    init(id:Unidoc.Edition,
        metadata:SymbolGraphMetadata,
        inline:SymbolGraph,
        link:LinkState?)
    {
        //  Is this the standard library? If so, is it a release version?
        let swift:PatchVersion?
        if  case .swift = metadata.package.name,
            case nil = metadata.swift.nightly
        {
            swift = metadata.swift.version
        }
        else
        {
            swift = nil
        }

        self.init(id: id,
            metadata: metadata,
            inline: inline,
            swift: swift,
            pins: [],
            link: link,
            type: .bson,
            size: 0)
    }
}
extension Unidoc.Snapshot
{
    @inlinable public
    var path:Unidoc.GraphPath { .init(edition: self.id, type: self.type) }

    /// Moves the inline symbol graph out of this snapshot document, encoding it to BSON and
    /// recording its size.
    ///
    /// This method returns nil if this snapshot does not contain an inline symbol graph.
    @inlinable public mutating
    func move() -> ArraySlice<UInt8>?
    {
        guard
        let inline:SymbolGraph = self.inline
        else
        {
            return nil
        }

        let document:BSON.Document = .init(encoding: inline)

        self.size = Int64.init(document.bytes.count)
        self.inline = nil

        return document.bytes
    }

    /// Wraps and returns the inline symbol graph from this snapshot document if present,
    /// delegates to the provided symbol graph loader otherwise.
    public
    func load<Loader>(with loader:Loader?) async throws -> SymbolGraphObject<Unidoc.Edition>
        where Loader:Unidoc.GraphLoader
    {
        if  let inline:SymbolGraph = self.inline
        {
            return .init(metadata: self.metadata, graph: inline, id: self.id)
        }
        else if
            let loader:Loader
        {
            let bytes:ArraySlice<UInt8> = try await loader.load(graph: self.path)
            let graph:SymbolGraph = try .init(bson: BSON.Document.init(bytes: bytes))

            return .init(metadata: self.metadata, graph: graph, id: self.id)
        }
        else
        {
            throw Unidoc.GraphLoaderError.unavailable
        }
    }
}
extension Unidoc.Snapshot
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case metadata = "M"
        case inline = "D"
        case swift = "S"
        case pins = "p"

        case link = "U"
        case type = "T"
        case size = "B"

        @available(*, deprecated, renamed: "inline")
        @inlinable public static
        var graph:Self { .inline }
    }
}
extension Unidoc.Snapshot:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.metadata] = self.metadata
        bson[.inline] = self.inline
        bson[.swift] = self.swift
        bson[.pins] = self.pins.isEmpty ? nil : self.pins

        bson[.link] = self.link
        bson[.type] = self.type
        bson[.size] = self.size
    }
}
extension Unidoc.Snapshot:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            metadata: try bson[.metadata].decode(),
            inline: try bson[.inline]?.decode(),
            swift: try bson[.swift]?.decode(),
            pins: try bson[.pins]?.decode() ?? [],
            link: try bson[.link]?.decode(),
            type: try bson[.type]?.decode() ?? .bson,
            size: try bson[.size]?.decode() ?? 0)
    }
}
