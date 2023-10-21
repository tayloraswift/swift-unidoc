import HTTP
import MD5
import System

final
actor Cache<Key> where Key:CacheKey
{
    nonisolated
    let assets:FilePath

    private
    var table:[Key: ServerResource]

    init(source assets:FilePath)
    {
        self.assets = assets
        self.table = [:]
    }
}
extension Cache
{
    func serve(_ request:Request) async throws -> ServerResponse
    {
        var resource:ServerResource = try self.load(request.key)

        if  let tag:MD5 = request.tag, case tag? = resource.hash
        {
            resource.content.drop()
        }

        return .ok(resource)
    }

    func clear()
    {
        self.table.removeAll(keepingCapacity: true)
    }
}
extension Cache
{
    private
    func load(_ key:Key) throws -> ServerResource
    {
        try
        {
            switch  (reload: key.reloadable, $0)
            {
            case    (reload: false, let cached?):
                return cached

            case    (reload: false, nil),
                    (reload: true, _):
                let asset:[UInt8] = try self.assets.appending(key.source).read()
                let hash:MD5 = .init(hashing: asset)
                let resource:ServerResource = .init(
                    content: .binary(asset),
                    type: key.type,
                    hash: hash)
                $0 = resource
                return resource
            }
        } (&self.table[key])
    }
}
