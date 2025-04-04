import HTTP
import MD5
import SystemIO

extension Unidoc
{
    public final
    actor Cache<Key> where Key:CacheKey
    {
        nonisolated
        let assets:FilePath

        private
        var table:[Key: HTTP.Resource]

        public
        init(source assets:FilePath)
        {
            self.assets = assets
            self.table = [:]
        }
    }
}
extension Unidoc.Cache
{
    func serve(_ request:Request) async throws -> HTTP.ServerResponse
    {
        var resource:HTTP.Resource = try self.load(request.key)

        if  let tag:MD5 = request.tag, case tag? = resource.hash
        {
            resource.content = nil
        }

        return .ok(resource)
    }

    func clear()
    {
        self.table.removeAll(keepingCapacity: true)
    }
}
extension Unidoc.Cache
{
    private
    func load(_ key:Key) throws -> HTTP.Resource
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
                let resource:HTTP.Resource = .init(
                    content: .init(body: .binary(asset), type: key.type),
                    hash: hash)
                $0 = resource
                return resource
            }
        } (&self.table[key])
    }
}
