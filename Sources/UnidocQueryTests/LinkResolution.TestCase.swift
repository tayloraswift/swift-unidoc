import MongoDB
import Testing
@_spi(testable) import UnidocDB

extension LinkResolution {
    struct TestCase {
        let name: String
        let path: [String]

        let internalLinks: KeyValuePairs<String, [String]>
        let externalLinks: KeyValuePairs<String, Bool>
        let fragmentLinks: Set<String>
        let brokenLinks: Set<String>
        let outlines: Int?

        init(
            name: String,
            path: [String],
            internalLinks: KeyValuePairs<String, [String]> = [:],
            externalLinks: KeyValuePairs<String, Bool> = [:],
            fragmentLinks: Set<String> = [],
            brokenLinks: Set<String> = [],
            outlines: Int? = nil
        ) {
            self.name = name
            self.path = path
            self.internalLinks = internalLinks
            self.externalLinks = externalLinks
            self.fragmentLinks = fragmentLinks
            self.brokenLinks = brokenLinks
            self.outlines = outlines
        }
    }
}
extension LinkResolution.TestCase {
    func run(in db: Unidoc.DB) async throws {
        let query: Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
            volume: .init("swift-test"),
            vertex: .init(casefolding: self.path[...], hash: nil)
        )

        let output: Unidoc.VertexOutput = try #require(try await db.query(with: query))
        let vertex: Unidoc.AnyVertex = try #require(output.principalVertex)

        let loadable: [Unidoc.Scalar: String] = output.adjacentVertices.reduce(into: [:]) {
            guard
            let shoot: Unidoc.Shoot = $1.shoot else {
                return
            }

            $0[$1.id] = shoot.hash.map { "\(shoot.stem) [\($0)]" } ?? "\(shoot.stem)"
        }

        var outlines: [Unidoc.Outline] = vertex.overview?.outlines ?? []
        if  let details: Unidoc.Passage = vertex.details {
            outlines += details.outlines
        }

        if  let count: Int = self.outlines {
            #expect(outlines.count == count)
        }

        var internalLinks: [String: [String]] = [:]
        var externalLinks: [String: Bool] = [:]
        var fragmentLinks: Set<String> = []
        var brokenLinks: Set<String> = []

        for outline: Unidoc.Outline in outlines {
            switch outline {
            case .fallback(let text?):
                brokenLinks.insert(text)

            case .fallback(nil):
                continue

            case .fragment(let display):
                fragmentLinks.insert(display)

            case .bare(line: _, let id):
                let full: String = try #require(loadable[id])

                internalLinks[full, default: []].append("__attribute")

            case .path(let display, let scalars):
                let id: Unidoc.Scalar = try #require(scalars.last)
                let full: String = try #require(loadable[id])

                internalLinks[full, default: []].append("\(display)")

            case .url(let url, let safe):
                externalLinks[url] = safe
            }
        }

        for (target, expectation): (String, [String]) in self.internalLinks {
            #expect(expectation == internalLinks[target])
        }
        for (target, expectation): (String, Bool) in self.externalLinks {
            #expect(expectation == externalLinks[target])
        }

        #expect(self.fragmentLinks == fragmentLinks)
        #expect(self.brokenLinks == brokenLinks)
    }
}
