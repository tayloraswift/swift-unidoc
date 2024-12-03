import HTML
import MarkdownRendering
import UnixTime

extension Unidoc.ServerLog
{
    /// A formatting abstraction that renders a list of ``PluginMessage`` as a sequence of `li`
    /// elements with relative timestamps.
    ///
    /// You should not store ``PluginMessageList``s for a long period of time, because they
    /// contain a current time that will become stale if not immediately rendered.
    @frozen public
    struct MessageList<Items> where Items:RandomAccessCollection<Message>
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
extension Unidoc.ServerLog.MessageList:HTML.OutputStreamable
{
    @inlinable public
    static func += (ol:inout HTML.ContentEncoder, self:Self)
    {
        for message:Unidoc.ServerLog.Message in self.items.reversed()
        {
            ol[.li]
            {
                $0[.header] = message.header(now: self.now)
                $0[.div] = message.bytecode.safe
            }
        }
    }
}
