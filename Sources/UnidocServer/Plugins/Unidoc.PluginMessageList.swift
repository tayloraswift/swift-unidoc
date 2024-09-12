import DequeModule
import HTML
import UnixTime

extension Unidoc
{
    /// A formatting abstraction that renders a list of ``PluginMessage`` as a sequence of `li`
    /// elements with relative timestamps.
    ///
    /// You should not store ``PluginMessageList``s for a long period of time, because they
    /// contain a current time that will become stale if not immediately rendered.
    @frozen public
    struct PluginMessageList<Items> where Items:RandomAccessCollection<PluginMessage>
    {
        @usableFromInline
        let items:Items
        @usableFromInline
        let now:UnixAttosecond

        @inlinable public
        init(items:Items, now:UnixAttosecond)
        {
            self.items = items
            self.now = now
        }
    }
}
extension Unidoc.PluginMessageList:HTML.OutputStreamable
{
    @inlinable public
    static func += (ol:inout HTML.ContentEncoder, self:Self)
    {
        for message:Unidoc.PluginMessage in self.items
        {
            ol[.li]
            {
                $0[.header]
                {
                    $0[.h3] { message.event.h3(&$0) }
                    $0[.div] = message.header(now: self.now)
                }

                $0[.dl] { message.event.dl(&$0) }
            }
        }
    }
}
