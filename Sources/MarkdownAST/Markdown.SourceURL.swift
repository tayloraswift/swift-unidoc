import Sources

extension Markdown {
    @frozen public struct SourceURL {
        public let provenance: Provenance
        public var scheme: String?
        public var suffix: SourceString

        @inlinable init(
            scheme: String?,
            suffix: SourceString,
            provenance: Provenance = .attribute
        ) {
            self.provenance = provenance
            self.scheme = scheme
            self.suffix = suffix
        }
    }
}
extension Markdown.SourceURL: CustomStringConvertible {
    @inlinable public var description: String {
        self.scheme.map { "\($0):\(self.suffix)" } ?? "\(self.suffix)"
    }
}
extension Markdown.SourceURL {
    @usableFromInline init(url: Markdown.SourceString, provenance: Provenance = .attribute) {
        self.init(scheme: nil, suffix: url, provenance: provenance)

        //  URL parsing is incredibly tough.
        //
        //  This problem is complicated significantly by the fact that Apple uses a
        //  [non-standard](https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml)
        //  `doc:` scheme for documentation links.
        //
        //  We need to do this in order to avoid emitting unresolved relative URLs, as such
        //  URLs would never work properly for the user.
        guard
        let colon: String.Index = self.suffix.string.firstIndex(of: ":") else {
            return
        }

        scheme:
        for codepoint: Unicode.Scalar in self.suffix.string.unicodeScalars[..<colon] {
            switch codepoint {
            case "+":           continue
            case "-":           continue
            case ".":           continue
            case "0" ... "9":   continue
            case "A" ... "Z":   continue
            case "a" ... "z":   continue
            //  This isn’t a scheme at all!
            default:            return
            }
        }

        self.scheme = .init(url.string[..<colon])
        self.suffix.string.removeSubrange(...colon)
    }
}
