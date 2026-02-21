import HTML
import Unidoc

extension Unidoc {
    struct ConformingTypesHeader: Identifiable {
        private let heading: ConformingTypesHeading
        private let culture: Unidoc.LinkReference<Unidoc.CultureVertex>

        let id: String

        init(
            heading: ConformingTypesHeading,
            culture: Unidoc.LinkReference<Unidoc.CultureVertex>,
            id: String
        ) {
            self.heading = heading
            self.culture = culture
            self.id = id
        }
    }
}
extension Unidoc.ConformingTypesHeader: HTML.OutputStreamableAnchor {
    static func += (header: inout HTML.ContentEncoder, self: Self) {
        header[.h2] {
            $0[.a] { $0.href = "#\(self.id)" } = "Conforming types"
            $0 += " in "
            $0[.a] { $0.href = self.culture.target?.url } = "\(self.culture.vertex.module.id)"
        }
    }
}
