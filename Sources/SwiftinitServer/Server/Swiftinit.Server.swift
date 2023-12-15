import Media
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

    var secure:Bool { self.loop.secure }
    var format:Swiftinit.RenderFormat { self.loop.format }
    func format(_ accept:AcceptType) -> Swiftinit.RenderFormat { self.loop.format(accept) }

    var plugins:Swiftinit.Plugins { self.loop.plugins }
    var db:Swiftinit.DB { self.loop.db }
}
