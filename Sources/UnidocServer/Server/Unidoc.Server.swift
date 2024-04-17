import GitHubAPI
import UnidocRender
import UnidocProfiling

extension Unidoc
{
    @frozen public
    struct Server:~Copyable
    {
        @usableFromInline
        let loop:ServerLoop
        @usableFromInline
        let tour:ServerTour

        init(_ loop:ServerLoop, tour:ServerTour)
        {
            self.loop = loop
            self.tour = tour
        }
    }
}
extension Unidoc.Server
{
    @inlinable public
    var plugins:[String: any Unidoc.ServerPlugin] { self.loop.plugins }
    @inlinable public
    var context:Unidoc.ServerPluginContext { self.loop.context }

    @inlinable public
    var secure:Bool { self.loop.secure }

    @inlinable public
    var github:GitHub.Integration? { self.loop.github }
    @inlinable public
    var bucket:Unidoc.Buckets { self.loop.bucket }

    @inlinable public
    var format:Unidoc.RenderFormat { self.loop.format }
    @inlinable public
    var db:Unidoc.Database { self.loop.db }
}
