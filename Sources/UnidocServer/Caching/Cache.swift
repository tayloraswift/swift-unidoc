import HTTP
import MD5
import System

final
actor Cache<Key> where Key:CacheKey
{
    nonisolated
    let assets:FilePath
    nonisolated
    let reload:Bool

    private
    var table:[Key: ServerResource]

    init(source assets:FilePath, reload:Bool)
    {
        self.assets = assets
        self.reload = reload

        self.table = [:]
    }
}
extension Cache
{
    func load(_ key:Key) throws -> ServerResource
    {
        try
        {
            switch  (reload: self.reload && key.reloadable, $0)
            {
            case    (reload: false, let cached?):
                return cached

            case    (reload: false, nil),
                    (reload: true, _):
                let asset:[UInt8] = try self.assets.appending(key.source).read()
                let hash:MD5 = .init(hashing: asset)
                let resource:ServerResource = .init(.one(canonical: nil),
                    content: .binary(asset),
                    type: key.type,
                    hash: hash)
                $0 = resource
                return resource
            }
        } (&self.table[key])
    }
}
