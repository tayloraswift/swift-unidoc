extension SSGC
{
    @frozen public
    enum StatusUpdate:UInt8, Equatable, Sendable
    {
        case success = 0

        case failedToCloneRepository = 1
        case failedToReadManifest
        case failedToReadManifestForDependency
        case failedToResolveDependencies
        case failedToBuild
        case failedToExtractSymbolGraph
        case failedToLoadSymbolGraph
        case failedToLinkSymbolGraph
    }
}
