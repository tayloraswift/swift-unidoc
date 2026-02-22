import Sources
import SymbolGraphParts
import Symbols

extension SSGC.Extension {
    @frozen public struct Block: Equatable {
        public let location: SourceLocation<Symbol.File>?
        public let comment: SSGC.DocumentationComment?

        init?(location: SourceLocation<Symbol.File>?, comment: SSGC.DocumentationComment?) {
            if  case (nil, nil) = (location, comment) {
                return nil
            }

            self.location = location
            self.comment = comment
        }
    }
}
