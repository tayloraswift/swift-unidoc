import HTTPServer
import Media
import System

protocol CacheKey:RawRepresentable<String>, Hashable, Sendable
{
    var requirement:CacheReloading? { get }
    var source:[FilePath.Component] { get }
    var type:MediaType { get }
}
extension CacheKey
{
    func load(from cache:Cache<Self>) async throws -> ServerResponse?
    {
        try await cache.load(self).map(ServerResponse.resource(_:))
    }
}
