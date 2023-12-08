import UnidocPages
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
    var atomics:Swiftinit.Counters
    {
        _read { yield self.loop.atomics }
    }

    var secured:Bool { self.loop.secured }
    var assets:StaticAssets { self.loop.assets }

    var plugins:Swiftinit.Plugins { self.loop.plugins }
    var db:Swiftinit.DB { self.loop.db }
}
