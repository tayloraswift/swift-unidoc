import NIOPosix
import NIOSSL
import UnidocDB
import UnixCalendar
import UnixTime

extension Unidoc
{
    @frozen public
    struct PluginContext<Event> where Event:ServerEvent
    {
        @usableFromInline
        let shared:(any ServerLogger)?
        @usableFromInline
        let plugin:String

        public
        let client:NIOSSLContext
        public
        let db:DB

        @inlinable public
        init(
            logger shared:(any ServerLogger)?,
            plugin:String,
            client:NIOSSLContext,
            db:DB)
        {
            self.shared = shared
            self.plugin = plugin
            self.client = client
            self.db = db
        }
    }
}
extension Unidoc.PluginContext
{
    @inlinable public
    func log(event:Event, date:UnixAttosecond = .now())
    {
        self.shared?.log(event: event, from: self.plugin, date: date)
    }
}
