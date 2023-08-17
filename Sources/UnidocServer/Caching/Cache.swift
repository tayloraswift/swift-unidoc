import HTTPServer
import MD5
import System

final
actor Cache<Key> where Key:CacheKey
{
    nonisolated
    let reloading:CacheReloading
    nonisolated
    let assets:FilePath

    private
    var table:[Key: ServerResource]

    init(reloading:CacheReloading, from assets:FilePath)
    {
        self.reloading = reloading
        self.assets = assets

        self.table = [:]
    }
}
extension Cache
{
    func load(_ key:Key) throws -> ServerResource?
    {
        let mode:CacheReloading = key.requirement ?? self.reloading
        if  mode > self.reloading
        {
            return nil
        }

        return try
        {
            switch (mode, $0)
            {
            case    (.cold, let cached?):
                return cached

            case    (.cold, nil),
                    (.hot, _):
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
