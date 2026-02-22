import Sources
import Symbols

extension SSGC {
    @frozen public struct DocumentationComment: Equatable {
        public let start: SourcePosition?
        public let text: String

        init?(_ text: String, at start: SourcePosition?) {
            if  text.isEmpty {
                return nil
            }

            self.start = start
            self.text = text
        }
    }
}
