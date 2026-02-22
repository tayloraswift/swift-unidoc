import Sources
import Symbols

extension Markdown.SwiftLanguage {
    @frozen public struct IndexMarker {
        public let position: SourcePosition
        public let symbol: Symbol.USR?
        public let phylum: Phylum.Decl?

        @inlinable public init(
            position: SourcePosition,
            symbol: Symbol.USR?,
            phylum: Phylum.Decl?
        ) {
            self.position = position
            self.symbol = symbol
            self.phylum = phylum
        }
    }
}
extension Markdown.SwiftLanguage.IndexMarker: CustomStringConvertible {
    public var description: String {
        """
        (\(self.position): \
        \(self.symbol?.description ?? "local"), \(self.phylum?.name ?? "unknown"))
        """
    }
}
