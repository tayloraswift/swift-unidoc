import HTML
import URI

extension Unidoc {
    struct StatsThumbnail {
        private let target: URI
        private let census: Unidoc.Census
        private let domain: String
        private let title: String

        init(target: URI, census: Unidoc.Census, domain: String, title: String) {
            self.target = target
            self.census = census
            self.domain = domain
            self.title = title
        }
    }
}
extension Unidoc.StatsThumbnail: HTML.OutputStreamable {
    static func += (div: inout HTML.ContentEncoder, self: Self) {
        let url: String = "\(self.target)"

        div[.div, { $0.class = "charts" }] {
            $0[.div] {
                $0[.p] {
                    let target: Unidoc.StatsHeading = .documentationCoverage
                    $0[.a] { $0.href = "\(url)#\(target.id)" } = "Coverage"
                }

                $0[.figure] {
                    $0.class = "chart coverage"
                } = self.census.unweighted.coverage.disc {
                    """
                    \($1) percent of the declarations in \(self.domain) are \($0.name)
                    """
                }
            }

            $0[.div] {
                $0[.p] {
                    let target: Unidoc.StatsHeading = .interfaceBreakdown
                    $0[.a] { $0.href = "\(url)#\(target.id)" } = "Declarations"
                }

                $0[.figure] {
                    $0.class = "chart decl"
                } = self.census.unweighted.decls.disc {
                    """
                    \($1) percent of the declarations in \(self.domain) are \($0.name)
                    """
                }
            }

            $0[.div] {
                $0[.p] {
                    let target: Unidoc.StatsHeading = .interfaceLayers
                    $0[.a] { $0.href = "\(url)#\(target.id)" } = "Interfaces"
                }

                $0[.figure] {
                    $0.class = "chart spis"
                } = self.census.interfaces.disc {
                    """
                    \($1) percent of the declarations in \(self.domain) are \($0.name)
                    """
                }
            }
        }

        div[.a] { $0.href = url } = self.title
    }
}
