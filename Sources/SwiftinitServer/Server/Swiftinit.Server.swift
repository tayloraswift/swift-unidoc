import GitHubAPI
import HTTP
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
    var atomics:Swiftinit.Counters { _read { yield self.loop.atomics } }

    var plugins:[String: any Swiftinit.ServerPlugin] { self.loop.plugins }
    var context:Swiftinit.ServerPluginContext { self.loop.context }

    var secure:Bool { self.loop.secure }

    var github:GitHub.Integration? { self.loop.github }

    var format:Swiftinit.RenderFormat { self.loop.format }
    var db:Swiftinit.DB { self.loop.db }
}
