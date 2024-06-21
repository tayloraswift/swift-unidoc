import HTML
import UnidocRender

extension Unidoc
{
    @frozen public
    struct CollectionEventsPage<Visitor>:Sendable where Visitor:CollectionVisitor
    {
        @usableFromInline
        let events:EventBuffer<Visitor.Event>

        @inlinable public
        init(events:EventBuffer<Visitor.Event>)
        {
            self.events = events
        }
    }
}
extension Unidoc.CollectionEventsPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
    @inlinable public
    var title:String { Visitor.title }
}
extension Unidoc.CollectionEventsPage:Unidoc.AdministrativePage
{
    @inlinable public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.h1] = Visitor.title
        main[.section, { $0.class = "events" }]
        {
            $0[.h2] = "Events"
            $0[.ol] { $0.class = "events" } = self.events.list(now: format.time)
        }
    }
}
