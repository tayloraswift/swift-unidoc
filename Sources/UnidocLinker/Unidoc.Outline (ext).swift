import UnidocRecords

extension Unidoc.Outline {
    static func url(sanitizing url: String) -> Self {
        guard let colon: String.Index = url.firstIndex(of: ":"),
        case "https" = url[..<colon] else {
            return .url(url, safe: false)
        }

        //  Skip the two slashes.
        guard let start: String.Index = url.index(colon, offsetBy: 3, limitedBy: url.endIndex),
        case "//" = url[url.index(after: colon) ..< start] else {
            return .url(url, safe: false)
        }

        let domain: Substring

        if  let slash: String.Index = url[start...].firstIndex(of: "/") {
            domain = url[start ..< slash]
        } else {
            domain = url[start...]
        }

        let root: Substring
        if  let j: String.Index = domain.lastIndex(of: "."),
            let i: String.Index = domain[..<j].lastIndex(of: ".") {
            root = domain[domain.index(after: i)...]
        } else {
            root = domain
        }

        //  We will follow links to GitHub and reputable open-source indexes.
        let safe: Bool = switch root {
        case "freebsd.org":     true
        case "github.com":      true
        case "ietf.org":        true
        case "man7.org":        true
        case "mozilla.org":     true
        case "scala-lang.org":  true
        case "swiftinit.org":   true
        case "swift.org":       true
        case "wikipedia.org":   true
        default:                false
        }

        return .url(url, safe: safe)
    }
}
