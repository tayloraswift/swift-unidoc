import S3
import S3Client
import UnidocDB

extension Unidoc
{
    public
    struct GraphLinkerPlugin:Sendable
    {
        public
        let status:AtomicPointer<CollectionEventsPage<GraphLinker>>
        let bucket:AWS.S3.Bucket?

        public
        init(bucket:AWS.S3.Bucket?)
        {
            self.status = .init()
            self.bucket = bucket
        }
    }
}
extension Unidoc.GraphLinkerPlugin:Identifiable
{
    @inlinable public
    var id:String { "linker" }
}
extension Unidoc.GraphLinkerPlugin:Unidoc.ServerPlugin
{
    public
    func run(in context:Unidoc.ServerPluginContext, with db:Unidoc.Database) async throws
    {
        var linker:Unidoc.GraphLinker = .init(updating: self.status, graphs: self.bucket.map
        {
            .init(threads: context.threads, niossl: context.niossl, bucket: $0)
        })
        try await linker.watch(db: db)
    }
}
