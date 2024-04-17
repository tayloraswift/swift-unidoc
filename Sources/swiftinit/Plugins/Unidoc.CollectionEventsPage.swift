import Atomics
import HTML
import HTTPServer
import IP
import UnixTime
import URI

extension Unidoc
{
    struct CollectionEventsPage<Visitor>:Sendable where Visitor:CollectionVisitor
    {
        private
        let entries:[EventBuffer<Visitor.Event>.Entry]

        init(entries:[EventBuffer<Visitor.Event>.Entry])
        {
            self.entries = entries
        }
    }
}
extension Unidoc.CollectionEventsPage
{
    init(from buffer:borrowing Unidoc.EventBuffer<Visitor.Event>)
    {
        //  This will be sent concurrently, so it will almost certainly
        //  end up being copied anyway.
        self.init(entries: [_].init(buffer.entries))
    }
}
extension Unidoc.CollectionEventsPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
    var title:String { Visitor.title }
}
extension Unidoc.CollectionEventsPage:Unidoc.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        let now:UnixInstant = .now()

        main[.h1] = Visitor.title
        main[.section, { $0.class = "events" }]
        {
            $0[.h2] = "Events"
            $0[.ol, { $0.class = "events" }]
            {
                for entry:Unidoc.EventBuffer<Visitor.Event>.Entry in self.entries.reversed()
                {
                    $0[.li]
                    {
                        $0[.div, .p] = entry.time(now: now)
                        $0[.div] = entry.event
                    }
                }
            }
        }
    }
}
