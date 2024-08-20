import MongoDB
import Testing_
@_spi(testable)
import UnidocDB

extension LinkResolution
{
    struct TestCase
    {
        let name:String
        let path:[String]

        let internalLinks:KeyValuePairs<String, [String]>
        let externalLinks:KeyValuePairs<String, Bool>
        let fragmentLinks:[String]
        let brokenLinks:[String]
        let outlines:Int?

        init(
            name:String,
            path:[String],
            internalLinks:KeyValuePairs<String, [String]> = [:],
            externalLinks:KeyValuePairs<String, Bool> = [:],
            fragmentLinks:[String] = [],
            brokenLinks:[String] = [],
            outlines:Int? = nil)
        {
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
extension LinkResolution.TestCase
{
    func run(tests:TestGroup, db:Unidoc.DB) async throws
    {
        let query:Unidoc.VertexQuery<Unidoc.LookupAdjacent> = .init(
            volume: .init("swift-test"),
            vertex: .init(path: self.path[...], hash: nil))

        guard
        let output:Unidoc.VertexOutput = tests.expect(
            value: try await db.session.query(database: db.id, with: query)),
        let vertex:Unidoc.AnyVertex = tests.expect(
            value: output.principal?.vertex)
        else
        {
            return
        }

        let loadable:[Unidoc.Scalar: String] = output.vertices.reduce(into: [:])
        {
            guard
            let shoot:Unidoc.Shoot = $1.shoot
            else
            {
                return
            }

            $0[$1.id] = shoot.hash.map { "\(shoot.stem) [\($0)]" } ?? "\(shoot.stem)"
        }

        var outlines:[Unidoc.Outline] = vertex.overview?.outlines ?? []
        if  let details:Unidoc.Passage = vertex.details
        {
            outlines += details.outlines
        }

        if  let count:Int = self.outlines,
            let tests:TestGroup = tests / "OutlineCount"
        {
            tests.expect(outlines.count ==? count)
        }

        var internalLinks:[String: [String]] = [:]
        var externalLinks:[String: Bool] = [:]
        var fragmentLinks:Set<String> = []
        var brokenLinks:Set<String> = []

        for outline:Unidoc.Outline in outlines
        {
            switch outline
            {
            case .fallback(let text?):
                brokenLinks.insert(text)

            case .fallback(nil):
                continue

            case .fragment(let display):
                fragmentLinks.insert(display)

            case .bare(line: _, let id):
                guard
                let id:Unidoc.Scalar = tests.expect(value: id),
                let full:String = tests.expect(value: loadable[id])
                else
                {
                    continue
                }

                internalLinks[full, default: []].append("__attribute")

            case .path(let display, let scalars):
                guard
                let id:Unidoc.Scalar = tests.expect(value: scalars.last),
                let full:String = tests.expect(value: loadable[id])
                else
                {
                    continue
                }

                internalLinks[full, default: []].append("\(display)")

            case .url(let url, let safe):
                externalLinks[url] = safe
            }
        }

        for (target, expectation):(String, [String]) in self.internalLinks
        {
            if  let test:TestGroup = tests / "InternalLinks" / target
            {
                test.expect(expectation ..? internalLinks[target] ?? [])
            }
        }
        for (target, expectation):(String, Bool) in self.externalLinks
        {
            if  let test:TestGroup = tests / "ExternalLinks" / target
            {
                test.expect(expectation ==? externalLinks[target])
            }
        }
        if  let test:TestGroup = tests / "FragmentLinks"
        {
            test.expect(self.fragmentLinks **? fragmentLinks)
        }
        if  let test:TestGroup = tests / "BrokenLinks"
        {
            test.expect(self.brokenLinks **? brokenLinks)
        }
    }
}
