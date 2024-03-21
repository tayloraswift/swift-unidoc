import S3
import S3Client
import SwiftinitPlugins
import UnidocDB

extension Swiftinit
{
    struct LinkerPlugin:Sendable
    {
        let status:AtomicPointer<Unidoc.CollectionEventsPage<Linker>>
        let bucket:AWS.S3.Bucket?

        init(bucket:AWS.S3.Bucket?)
        {
            self.status = .init()
            self.bucket = bucket
        }
    }
}
extension Swiftinit.LinkerPlugin:Identifiable
{
    var id:String { "linker" }
}
extension Swiftinit.LinkerPlugin:Swiftinit.ServerPlugin
{
    func run(in context:Swiftinit.ServerPluginContext, with db:Swiftinit.DB) async throws
    {
        var linker:Swiftinit.Linker = .init(updating: self.status, graphs: self.bucket.map
        {
            .init(threads: context.threads, niossl: context.niossl, bucket: $0)
        })
        try await linker.watch(db: db.unidoc, with: db.sessions)
    }
}
