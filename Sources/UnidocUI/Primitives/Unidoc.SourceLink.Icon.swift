extension Unidoc.SourceLink {
    enum Icon {
        case github
    }
}
extension Unidoc.SourceLink.Icon: Identifiable {
    var id: String {
        switch self {
        case .github:   "github"
        }
    }
}
