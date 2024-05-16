extension SSGC
{
    @frozen public
    enum StatusUpdate:UInt8, Equatable, Sendable
    {
        case didCloneRepository = 0
        case didResolveDependencies

        case success = 128

        case failedToCloneRepository
        case failedToReadManifest
        case failedToReadManifestForDependency
        case failedToResolveDependencies
        case failedToBuild
        case failedToExtractSymbolGraph
        case failedToLoadSymbolGraph
        case failedToLinkSymbolGraph

        case failedForUnknownReason
    }
}
