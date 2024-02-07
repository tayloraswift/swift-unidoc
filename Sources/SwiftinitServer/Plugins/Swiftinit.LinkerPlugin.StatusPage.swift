import Atomics
import HTML
import HTTPServer
import IP
import UnixTime
import URI

extension Swiftinit.LinkerPlugin
{
    struct StatusPage:Sendable
    {
        private
        let entries:[Swiftinit.EventBuffer<Swiftinit.Linker.Event>.Entry]

        init(entries:[Swiftinit.EventBuffer<Swiftinit.Linker.Event>.Entry])
        {
            self.entries = entries
        }
    }
}
extension Swiftinit.LinkerPlugin.StatusPage
{
    init(from buffer:borrowing Swiftinit.EventBuffer<Swiftinit.Linker.Event>)
    {
        //  This will be sent concurrently, so it will almost certainly
        //  end up being copied anyway.
        self.init(entries: [_].init(buffer.entries))
    }
}
extension Swiftinit.LinkerPlugin.StatusPage:Swiftinit.RenderablePage, Swiftinit.DynamicPage
{
    var title:String { "Linker plugin" }
}
extension Swiftinit.LinkerPlugin.StatusPage:Swiftinit.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        let now:UnixInstant = .now()

        main[.h1] = "Linker plugin"
        main[.section, { $0.class = "events" }]
        {
            $0[.h2] = "Events"
            $0[.ol, { $0.class = "events" }]
            {
                for entry:Swiftinit.EventBuffer<Swiftinit.Linker.Event>.Entry
                    in self.entries.reversed()
                {
                    $0[.li]
                    {
                        $0[.p] = entry.time(now: now)
                        $0[.p] = "\(entry.event)"
                    }
                }
            }
        }
    }
}
