import HTML

extension Unidoc.SegregatedSection {
    struct Heading {
        let type: Unidoc.SegregatedType
        let id: String

        init(type: Unidoc.SegregatedType, id: String) {
            self.type = type
            self.id = id
        }
    }
}
extension Unidoc.SegregatedSection.Heading: HTML.OutputStreamableHeading {
    var display: String { "\(self.type)" }
}
