import HTTPServer
import Media
import System

protocol CacheKey:RawRepresentable<String>, LosslessStringConvertible, Hashable, Sendable
{
    var requirement:CacheReloading? { get }
    var source:[FilePath.Component] { get }
    var type:MediaType { get }
}
extension CacheKey
{
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }

    var description:String { self.rawValue }
}
extension CacheKey
{
    func load(from cache:Cache<Self>) async throws -> ServerResponse?
    {
        try await cache.load(self).map(ServerResponse.resource(_:))
    }
}
