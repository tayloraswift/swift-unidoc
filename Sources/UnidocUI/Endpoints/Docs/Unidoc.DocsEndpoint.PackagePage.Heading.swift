import HTML

extension Unidoc.DocsEndpoint.PackagePage {
    enum Heading {
        case repository
        case dependencies
        case platforms
        case linkage
    }
}
extension Unidoc.DocsEndpoint.PackagePage.Heading: Identifiable {
    var id: String {
        switch self {
        case .repository:   "ss:package-repository"
        case .dependencies: "ss:package-dependencies"
        case .platforms:    "ss:platform-requirements"
        case .linkage:      "ss:snapshot-information"
        }
    }
}
extension Unidoc.DocsEndpoint.PackagePage.Heading: HTML.OutputStreamableHeading {
    var display: String {
        switch self {
        case .repository:   "Package repository"
        case .dependencies: "Package dependencies"
        case .platforms:    "Platform requirements"
        case .linkage:      "Linkage information"
        }
    }
}
