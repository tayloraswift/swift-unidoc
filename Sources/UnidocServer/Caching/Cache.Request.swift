import HTTP
import MD5

extension Cache
{
    struct Request:Equatable, Hashable, Sendable
    {
        let key:Key
        let tag:MD5?

        init(_ key:Key, tag:MD5?)
        {
            self.key = key
            self.tag = tag
        }
    }
}
extension Cache.Request
{
    func load(from cache:Cache<Key>) async throws -> ServerResponse
    {
        var resource:ServerResource = try await cache.load(self.key)

        if  let tag:MD5 = self.tag,
            case tag? = resource.hash
        {
            resource.content.drop()
        }

        return .ok(resource)
    }
}
