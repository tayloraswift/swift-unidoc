import FNV1
import ModuleGraphs
import SemanticVersions
import Symbols
import UnidocRecords

/// A deep query is a query for a single code-level entity,
/// such as a declaration or a module.
@frozen public
struct DeepQuery:Equatable, Sendable
{
    /// The set of unidoc planes to filter by.
    public
    var planes:Planes
    public
    var package:PackageIdentifier
    public
    var version:Substring?

    /// Selects a declaration by mangled symbol name. If present,
    /// ``stem`` and ``hash`` are ignored.
    public
    var decl:Symbol.Decl?

    public
    var stem:Record.Stem
    public
    var hash:FNV24?

    @inlinable internal
    init(_ planes:Planes,
        package:PackageIdentifier,
        version:Substring?,
        decl:Symbol.Decl?,
        stem:Record.Stem,
        hash:FNV24?)
    {
        self.planes = planes
        self.package = package
        self.version = version
        self.decl = decl
        self.stem = stem
        self.hash = hash
    }
}
extension DeepQuery
{
    @inlinable public
    init(_ planes:Planes,
        package:PackageIdentifier,
        version:Substring?,
        decl:Symbol.Decl? = nil)
    {
        self.init(planes,
            package: package,
            version: version,
            decl: decl,
            stem: "",
            hash: nil)
    }

    @inlinable public
    init(_ planes:Planes,
        package:PackageIdentifier,
        version:Substring?,
        stem:Record.Stem,
        hash:FNV24? = nil)
    {
        self.init(planes,
            package: package,
            version: version,
            decl: nil,
            stem: stem,
            hash: hash)
    }

    public
    init(_ planes:Planes, _ trunk:String, _ stem:ArraySlice<String>, hash:FNV24? = nil)
    {
        if  let colon:String.Index = trunk.firstIndex(of: ":")
        {
            self.init(planes,
                package: .init(trunk[..<colon]),
                version: trunk[trunk.index(after: colon)...],
                stem: .init(path: stem),
                hash: hash)
        }
        else
        {
            self.init(planes,
                package: .init(trunk),
                version: nil,
                stem: .init(path: stem),
                hash: hash)
        }
    }
}
extension DeepQuery
{
    public
    init(legacy planes:Planes, _ first:String, _ rest:ArraySlice<String>,
        overload:String?,
        from:String?)
    {
        if  case true? = first.first?.isNumber,
            let next:String = rest.first,
                rest.count < 64 // Protect the server from stack overflow DoS
        {
            self.init(legacy: planes, next, rest.dropFirst(),
                overload: overload,
                from: from)

            if  case nil = self.version,
                let version:NumericVersion = .init(first)
            {
                self.version = "\(PatchVersion.init(padding: version))"
            }
            //  Legacy Biome urls also supported a weird nightly date version
            //  format (`reference/2022-8-24/swift`). Unidoc doesn’t distinguish
            //  between nightly snapshots unless explicitly tagged by the repo
            //  owner, so we just convert those to unversioned queries.
            return
        }

        let colony:PackageIdentifier
        let stem:ArraySlice<String>

        func desugared(namespace:some StringProtocol) -> String?
        {
            switch namespace
            {
            case "concurrency":         return "_concurrency"
            case "differentiation":     return "_differentiation"
            case "dispatch":            return "dispatch"
            case "distributed":         return "distributed"
            case "foundation":          return "foundation"
            case "regexbuilder":        return "regexbuilder"
            case "regexparser":         return "_regexparser"
            case "stringprocessing":    return "_stringprocessing"
            case "swift":               return "swift"
            case _:                     return nil
            }
        }

        if  let dot:String.Index = first.firstIndex(of: "."),
            let namespace:String = desugared(namespace: first[..<dot])
        {
            colony = .swift
            stem = ["\(namespace)\(first[dot...])"] + rest
        }
        else if
            let namespace:String = desugared(namespace: first)
        {
            colony = .swift
            stem = ["\(namespace)"] + rest
        }
        else
        {
            colony = .init(first)
            stem = rest
        }

        let package:PackageIdentifier
        let version:NumericVersion?

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
        else
        {
            package = colony
            version = nil
        }

        self.init(planes,
            package: package,
            version: version.map{ "\(PatchVersion.init(padding: $0))" },
            decl: overload.map{ .init(rawValue: $0) } ?? nil,
            stem: .init(path: stem),
            hash: nil)
    }
}
