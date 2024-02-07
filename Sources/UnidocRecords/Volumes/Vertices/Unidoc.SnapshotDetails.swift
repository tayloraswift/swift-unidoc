import BSON
import SemanticVersions
import SHA1
import SymbolGraphs

extension Unidoc
{
    @frozen public
    struct SnapshotDetails:Equatable, Sendable
    {
        /// The ABI version of the symbol graph this volume was linked from.
        public
        var abi:PatchVersion

        /// The swift tools version from the symbol graph metadata.
        public
        var latestManifest:PatchVersion?
        public
        var extraManifests:[MinorVersion]
        /// Platform requirements read from the symbol graph, which in turn got them from a
        /// `Package.swift` manifest.
        public
        var requirements:[SymbolGraphMetadata.PlatformRequirement]
        /// The git commit hash from the symbol graph metadata.
        public
        var commit:SHA1?

        /// Top-level linker statistics.
        public
        var census:Unidoc.Census

        //  We don’t currently store linker errors, but if we did, they would go here.

        @inlinable public
        init(abi:PatchVersion,
            latestManifest:PatchVersion?,
            extraManifests:[MinorVersion],
            requirements:[SymbolGraphMetadata.PlatformRequirement],
            commit:SHA1?,
            census:Unidoc.Census = .init())
        {
            self.abi = abi
            self.latestManifest = latestManifest
            self.extraManifests = extraManifests
            self.requirements = requirements
            self.commit = commit
            self.census = census
        }
    }
}
extension Unidoc.SnapshotDetails
{
    public
    enum CodingKey:String, Sendable
    {
        case abi = "B"
        case latestManifest = "S"
        case extraManifests = "E"
        case requirements = "O"
        case commit = "H"
        case census = "C"
    }
}
extension Unidoc.SnapshotDetails:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.abi] = self.abi
        bson[.latestManifest] = self.latestManifest
        bson[.extraManifests] = self.extraManifests.isEmpty ? nil : self.extraManifests
        bson[.requirements] = self.requirements.isEmpty ? nil : self.requirements
        bson[.commit] = self.commit
        bson[.census] = self.census
    }
}
extension Unidoc.SnapshotDetails:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(abi: try bson[.abi].decode(),
            latestManifest: try bson[.latestManifest]?.decode(),
            extraManifests: try bson[.extraManifests]?.decode() ?? [],
            requirements: try bson[.requirements]?.decode() ?? [],
            commit: try bson[.commit]?.decode(),
            //  Deprojected when serving a redirect.
            census: try bson[.census]?.decode() ?? .init())
    }
}
