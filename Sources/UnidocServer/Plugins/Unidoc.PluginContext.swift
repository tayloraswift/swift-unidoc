import MarkdownABI
import NIOPosix
import NIOSSL
import UnidocDB
import UnixCalendar
import UnixTime

extension Unidoc {
    @frozen public struct PluginContext {
        @usableFromInline let logger: any ServerLogger
        @usableFromInline let plugin: String

        public let client: NIOSSLContext
        public let db: DB

        @inlinable public init(
            logger: any ServerLogger,
            plugin: String,
            client: NIOSSLContext,
            db: DB
        ) {
            self.logger = logger
            self.plugin = plugin
            self.client = client
            self.db = db
        }
    }
}
extension Unidoc.PluginContext {
    @inlinable public func log(
        at date: UnixAttosecond = .now(),
        encode: (inout Markdown.BinaryEncoder) -> ()
    ) {
        self.logger.log(as: .plugin(self.plugin), at: date, encode: encode)
    }
}
