import GitHubAPI
import HTTP
import JSON
import MongoDB
import S3
import Symbols
import UnidocProfiling

extension Swiftinit
{
    struct Server:~Copyable
    {
        private
        let loop:ServerLoop
        let tour:ServerTour

        init(_ loop:ServerLoop, tour:ServerTour)
        {
            self.loop = loop
            self.tour = tour
        }
    }
}
extension Swiftinit.Server
{
    var plugins:[String: any Swiftinit.ServerPlugin] { self.loop.plugins }
    var context:Swiftinit.ServerPluginContext { self.loop.context }

    var secure:Bool { self.loop.secure }

    var github:GitHub.Integration? { self.loop.github }
    var bucket:AWS.S3.Bucket? { self.loop.bucket }

    var format:Swiftinit.RenderFormat { self.loop.format }
    var db:Swiftinit.DB { self.loop.db }
}
