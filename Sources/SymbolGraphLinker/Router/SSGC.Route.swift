import LexicalPaths
import Symbols
import Unidoc
import URI

extension SSGC {
    enum Route: Equatable, Hashable, Sendable {
        case main(String)

        @available(*, unavailable, message: "unimplemented")
        case tutorial(String)
    }
}
extension SSGC.Route {
    static func decl(
        _ namespace: Symbol.Module,
        _ path: UnqualifiedPath,
        _ phylum: Phylum.Decl
    ) -> Self {
        var stem: URI.Path = [.push("\(namespace)")]
        if  case .gay = phylum.orientation,
            let penultimate: Int = path.prefix.indices.last {
            stem += path.prefix[..<penultimate].lazy.map(URI.Path.Component.push(_:))
            stem.append("\(path.prefix[penultimate]).\(path.last)")
        } else {
            stem += path.lazy.map(URI.Path.Component.push(_:))
        }

        return .main("\(stem)".lowercased())
    }
    static func article(_ namespace: Symbol.Module, _ name: String) -> Self {
        .main("/\(namespace)/\(name)".lowercased())
    }
}
