import BSON
import SemanticVersions
import SymbolGraphs
import Symbols
import Unidoc

extension Unidex
{
    @frozen public
    struct Snapshot:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Edition

        public
        var metadata:SymbolGraphMetadata
        public
        var graph:SymbolGraph

        /// Only present for standard library snapshots. This is used to automatically load
        /// the latest version of the standard library without querying git tags.
        public
        var swift:PatchVersion?
        public
        var pins:[Unidoc.Edition?]

        @inlinable internal
        init(id:Unidoc.Edition,
            metadata:SymbolGraphMetadata,
            graph:SymbolGraph,
            swift:PatchVersion?,
            pins:[Unidoc.Edition?])
        {
            self.id = id
            self.metadata = metadata
            self.graph = graph
            self.swift = swift
            self.pins = pins
        }
    }
}
extension Unidex.Snapshot
{
    @inlinable public
    init(id:Unidoc.Edition, metadata:SymbolGraphMetadata, graph:SymbolGraph)
    {
        //  Is this the standard library? If so, is it a release version?
        let swift:PatchVersion?
        if  case .swift = metadata.package,
            let version:SemanticVersion = metadata.swift.stable,
                version.release
        {
            swift = version.patch
        }
        else
        {
            swift = nil
        }

        self.init(id: id,
            metadata: metadata,
            graph: graph,
            swift: swift,
            pins: [])
    }
}
extension Unidex.Snapshot
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case metadata = "M"
        case graph = "D"
        case swift = "S"
        case pins = "p"
    }
}
extension Unidex.Snapshot:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.metadata] = self.metadata
        bson[.graph] = self.graph
        bson[.swift] = self.swift
        bson[.pins] = self.pins.isEmpty ? nil : self.pins
    }
}
extension Unidex.Snapshot:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            metadata: try bson[.metadata].decode(),
            graph: try bson[.graph].decode(),
            swift: try bson[.swift]?.decode(),
            pins: try bson[.pins]?.decode() ?? [])
    }
}
