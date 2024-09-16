import BSON
import SemanticVersions
import SymbolGraphs
import Symbols
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct Snapshot:Identifiable, Equatable, Sendable
    {
        public
        let id:Edition

        public
        var metadata:SymbolGraphMetadata
        /// Holds an optional inline symbol graph. Inline symbol graphs are bad for database
        /// performance, so this is only really used for local testing.
        public
        var inline:SymbolGraph?

        public
        var action:LinkerAction?

        /// Only present for standard library snapshots. This is used to automatically load the
        /// latest version of the standard library without querying git tags.
        public
        var swift:PatchVersion?
        /// Any dependencies that have been pinned for this snapshot.
        public
        var pins:[Edition?]

        /// Indicates the format (compressed or not) of the symbol graph. This is currently only
        /// meaningful for symbol graphs stored in Amazon S3.
        public
        var type:GraphType
        /// The size, in bytes, of the symbol graph. This is currently only meaningful for
        /// symbol graphs stored in Amazon S3.
        public
        var size:Int64

        /// Indicates if the symbol graph is no longer buildable from source. This flag prevents
        /// the automated build system from repeatedly attempting to build the package.
        ///
        /// Possible reasons for this include:
        ///
        /// -   The package no longer compiles using the latest version of its dependencies,
        ///     and its manifest does not constrain the dependencies to compatible versions.
        ///
        /// -   The package, or one of its dependencies, has been taken down from GitHub.
        ///
        /// -   The package only builds on a platform that is no longer supported by the hosting
        ///     service.
        ///
        /// -   The package suffers from a Swift (or Unidoc) compiler bug that prevents it from
        ///     being built.
        public
        var vintage:Bool

        @inlinable
        init(id:Edition,
            metadata:SymbolGraphMetadata,
            inline:SymbolGraph?,
            action:LinkerAction?,
            swift:PatchVersion?,
            pins:[Edition?],
            type:GraphType,
            size:Int64,
            vintage:Bool)
        {
            self.id = id
            self.metadata = metadata
            self.inline = inline
            self.action = action
            self.swift = swift
            self.pins = pins
            self.type = type
            self.size = size
            self.vintage = vintage
        }
    }
}
extension Unidoc.Snapshot
{
    @inlinable public
    init(id:Unidoc.Edition,
        metadata:SymbolGraphMetadata,
        inline:SymbolGraph,
        action:Unidoc.LinkerAction?)
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
            action: action,
            swift: swift,
            pins: [],
            type: .bson,
            size: 0,
            vintage: false)
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
            throw Unidoc.GraphLoaderError.unavailable(self.metadata.package.id)
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
        case action = "U"

        case swift = "S"
        case pins = "p"
        case type = "T"
        case size = "B"
        case vintage = "V"

        @available(*, deprecated, renamed: "inline")
        @inlinable public static
        var graph:Self { .inline }

        @available(*, deprecated, renamed: "action")
        @inlinable public static
        var link:Self { .action }
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
        bson[.action] = self.action

        bson[.swift] = self.swift
        bson[.pins] = self.pins.isEmpty ? nil : self.pins
        bson[.type] = self.type
        bson[.size] = self.size
        bson[.vintage] = self.vintage ? true : nil
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
            action: try bson[.action]?.decode(),
            swift: try bson[.swift]?.decode(),
            pins: try bson[.pins]?.decode() ?? [],
            type: try bson[.type]?.decode() ?? .bson,
            size: try bson[.size]?.decode() ?? 0,
            vintage: try bson[.vintage]?.decode() ?? false)
    }
}
