import BSON
import SemanticVersions
import SymbolGraphs

extension Volume
{
    @frozen public
    struct SnapshotDetails:Equatable, Sendable
    {
        /// The ABI version of the symbol graph this volume was linked from.
        public
        var abi:MinorVersion

        /// Platform requirements read from the symbol graph, which in turn got them from a
        /// `Package.swift` manifest.
        public
        var requirements:[SymbolGraphMetadata.PlatformRequirement]
        /// Top-level linker statistics.
        public
        var census:Volume.Census

        //  We don’t currently store linker errors, but if we did, they would go here.

        @inlinable public
        init(abi:MinorVersion,
            requirements:[SymbolGraphMetadata.PlatformRequirement],
            census:Volume.Census = .init())
        {
            self.abi = abi
            self.requirements = requirements
            self.census = census
        }
    }
}
extension Volume.SnapshotDetails
{
    public
    enum CodingKey:String, Sendable
    {
        case abi = "B"
        case requirements = "O"
        case census = "C"
    }
}
extension Volume.SnapshotDetails:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.abi] = self.abi
        bson[.requirements] = self.requirements.isEmpty ? nil : self.requirements
        bson[.census] = self.census
    }
}
extension Volume.SnapshotDetails:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(abi: try bson[.abi].decode(),
            requirements: try bson[.requirements]?.decode() ?? [],
            census: try bson[.census].decode())
    }
}
