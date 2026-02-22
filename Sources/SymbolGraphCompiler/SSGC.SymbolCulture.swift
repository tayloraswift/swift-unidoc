import SymbolGraphParts
import Symbols

extension SSGC {
    @frozen public struct SymbolCulture {
        public let language: Phylum.Language
        public let symbols: [SymbolDump]

        @inlinable public init(language: Phylum.Language, symbols: [SymbolDump]) {
            self.language = language
            self.symbols = symbols
        }
    }
}
