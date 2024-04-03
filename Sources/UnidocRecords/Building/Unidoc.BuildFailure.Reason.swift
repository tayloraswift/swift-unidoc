import BSON

extension Unidoc.BuildFailure
{
    @frozen public
    enum Reason:Int32, Equatable, Sendable
    {
        case timeout = 0
        case noValidVersion = 1
        case failedToCloneRepository = 2
        case failedToReadManifest = 3
        case failedToReadManifestForDependency = 4
        case failedToResolveDependencies = 5
        case failedToBuild = 6
        case failedToExtractSymbolGraph = 7
        case failedToLoadSymbolGraph = 8
        case failedToLinkSymbolGraph = 9
    }
}
extension Unidoc.BuildFailure.Reason:BSONDecodable, BSONEncodable
{
}
