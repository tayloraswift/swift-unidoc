import SemanticVersions
import Symbols
import UnidocQueries
import UnidocRecords

extension Unidoc.SymbolicRedirectQuery<Unidoc.Shoot>
{
    static
    func legacy(
        head:String,
        rest:ArraySlice<String>,
        from:String? = nil) -> Self
    {
        func desugared(namespace:some StringProtocol) -> String?
        {
            switch namespace
            {
            case "concurrency":         "_concurrency"
            case "differentiation":     "_differentiation"
            case "dispatch":            "dispatch"
            case "distributed":         "distributed"
            case "foundation":          "foundation"
            case "regexbuilder":        "regexbuilder"
            case "regexparser":         "_regexparser"
            case "stringprocessing":    "_stringprocessing"
            case "swift":               "swift"
            case _:                     nil
            }
        }

        var package:Symbol.Package = .swift
        var version:NumericVersion? = nil

        var head:String = head
        var rest:ArraySlice<String> = rest

        if  case true? = head.first?.isNumber,
            let next:String = rest.popFirst()
        {
            //  Legacy Biome urls also supported a weird nightly date version
            //  format (`reference/2022-8-24/swift`). Unidoc doesn’t distinguish
            //  between nightly snapshots unless explicitly tagged by the repo
            //  owner, so we just convert those to unversioned queries.
            version = .init(head)
            head = next

            if  let swift:NumericVersion = version
            {
                let swift:PatchVersion = .init(padding: swift)
                //  We don’t have any symbol graphs for these versions of swift.
                if  swift < .v(5, 8, 0)
                {
                    version = nil
                }
            }
        }

        let stem:ArraySlice<String>

        if  let dot:String.Index = head.firstIndex(of: "."),
            let namespace:String = desugared(namespace: head[..<dot])
        {
            stem = ["\(namespace)\(head[dot...])"] + rest
        }
        else if
            let namespace:String = desugared(namespace: head)
        {
            stem = ["\(namespace)"] + rest
        }
        else
        {
            package = .init(head)

            if  let next:String = rest.first,
                case true? = next.first?.isNumber
            {
                rest.removeFirst()

                version = .init(next)
                head = next
            }

            stem = rest
        }

        if  let from:String
        {
            if  let slash:String.Index = from.firstIndex(of: "/")
            {
                package = .init(from[..<slash])
                version = .init(from[from.index(after: slash)...])
            }
            else
            {
                package = .init(from)
                version = nil
            }
        }

        return .init(
            volume: .init(
                package: package,
                version: version.map { "\(PatchVersion.init(padding: $0))" }),
            lookup: .init(
                path: stem,
                hash: nil))
    }
}
