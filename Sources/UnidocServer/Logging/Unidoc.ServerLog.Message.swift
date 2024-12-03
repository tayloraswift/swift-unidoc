import MarkdownABI
import UnixCalendar
import UnixTime

extension Unidoc.ServerLog
{
    @frozen public
    struct Message:Sendable
    {
        @usableFromInline
        let bytecode:Markdown.Bytecode
        @usableFromInline
        let date:UnixAttosecond

        @inlinable public
        init(bytecode:Markdown.Bytecode, date:UnixAttosecond)
        {
            self.bytecode = bytecode
            self.date = date
        }
    }
}
extension Unidoc.ServerLog.Message
{
    @inlinable
    func header(now:UnixAttosecond) -> Unidoc.ServerLog.MessageHeader?
    {
        self.date.timestamp.map
        {
            .init(components: $0.components, dynamicAge: .init(now - self.date))
        }
    }
}
