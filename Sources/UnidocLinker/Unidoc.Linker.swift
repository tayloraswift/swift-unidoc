import LinkResolution
import MD5
import SemanticVersions
import Signatures
import SourceDiagnostics
import SymbolGraphs
import Symbols
import UCF
import Unidoc
import UnidocRecords

extension Unidoc
{
    /// A dynamic symbol graph linker.
    @frozen public
    struct Linker//:~Copyable https://github.com/apple/swift/issues/72136
    {
        var diagnostics:Diagnostics<Unidoc.Symbolicator>

        private
        let byPackageName:[Symbol.Package: Graph]
        private
        let byPackage:[Package: Graph]

        let current:Graph

        /// The set of all nodes in the current graph. These are the nodes being linked; all
        /// other nodes in this structure are merely used for context.
        let nodes:Set<Unidoc.Scalar>

        private
        init(
            byPackageName:[Symbol.Package: Graph],
            byPackage:[Package: Graph],
            current:Graph,
            nodes:Set<Unidoc.Scalar>)
        {
            self.byPackageName = byPackageName
            self.byPackage = byPackage
            self.current = current
            self.nodes = nodes

            self.diagnostics = .init()
        }
    }
}

extension Unidoc.Linker
{
    public
    init(
        linking primary:consuming SymbolGraphObject<Unidoc.Edition>,
        against others:borrowing [SymbolGraphObject<Unidoc.Edition>])
    {
        var upstream:UpstreamScalars = .init()

        for other:SymbolGraphObject<Unidoc.Edition> in copy others
        {
            for (citizen, symbol):(Int32, Symbol.Decl) in other.graph.decls.citizens
            {
                upstream.citizens[symbol] = other.id + citizen
            }
            for (culture, symbol):(Int, Symbol.Module) in zip(
                other.graph.cultures.indices,
                other.graph.namespaces)
            {
                upstream.cultures[symbol] = other.id + culture * .module
            }
        }

        //  Build two indexes for fast lookup by package identifier and package number.
        var byPackageName:[Symbol.Package: Graph] = .init(
            minimumCapacity: others.count)

        var byPackage:[Unidoc.Package: Graph] = .init(
            minimumCapacity: others.count)

        for other:SymbolGraphObject<Unidoc.Edition> in copy others
        {
            let other:Graph = .init(other, upstream: upstream)

            byPackageName[other.metadata.package.name] = other
            byPackage[other.id.package] = other
        }

        let current:Graph = .init(primary, upstream: upstream)

        self.init(
            byPackageName: byPackageName,
            byPackage: byPackage,
            current: current,
            nodes: current.scalars.decls[current.decls.nodes.indices].reduce(into: [])
            {
                if  let s:Unidoc.Scalar = $1
                {
                    $0.insert(s)
                }
            })
    }
}
extension Unidoc.Linker
{
    public mutating
    func link(primary metadata:SymbolGraphMetadata,
        pins pinnedDependencies:[Unidoc.Edition?],
        latestRelease:Unidoc.Edition?,
        thisRelease:PatchVersion?,
        as volume:Symbol.Volume,
        in realm:Unidoc.Realm?) -> Unidoc.Mesh
    {
        let boundaries:[Unidoc.Mesh.Boundary] = self.boundaries(pinned: pinnedDependencies)
        let interior:Unidoc.Mesh.Interior = .init(primary: metadata,
            pins: pinnedDependencies,
            with: &self)

        let metadata:Unidoc.VolumeMetadata = .init(id: self.current.id,
            dependencies: boundaries.map(\.target),
            display: metadata.display,
            refname: metadata.commit?.name,
            symbol: volume,
            latest: self.current.id == latestRelease,
            realm: realm,
            patch: thisRelease,
            products: interior.vertices.products.map
            {
                .init(shoot: $0.shoot, type: .stem(.package, nil))
            }
                .sorted
            {
                $0.shoot < $1.shoot
            },
            cultures: interior.vertices.cultures.map
            {
                .init(shoot: $0.shoot, type: .stem(.package, nil))
            }
                .sorted
            {
                $0.shoot < $1.shoot
            })

        return .init(latestRelease: latestRelease,
            packageABI: self.current.scalars.hash,
            boundaries: boundaries,
            metadata: metadata,
            interior: interior)
    }

    public consuming
    func status() -> DiagnosticMessages
    {
        let diagnostics:Diagnostics<Unidoc.Symbolicator> = self.diagnostics
        let symbols:Unidoc.Symbolicator = .init(context: self,
            base: self.current.metadata.root)

        return diagnostics.symbolicated(with: symbols)
    }
}
extension Unidoc.Linker
{
    private
    subscript(dynamic package:Symbol.Package) -> Graph?
    {
        self.current.metadata.package.name == package ?
        nil : self.byPackageName[package]
    }
    subscript(package:Symbol.Package) -> Graph?
    {
        self.current.metadata.package.name == package ?
        self.current : self.byPackageName[package]
    }
    subscript(package:Unidoc.Package) -> Graph?
    {
        self.current.id.package == package ?
        self.current : self.byPackage[package]
    }

    subscript(decl id:Unidoc.Scalar) -> SymbolGraph.Decl?
    {
        self[id.package]?.decls[id.citizen]?.decl
    }
}
extension Unidoc.Linker
{
    func expand(_ vector:(Unidoc.Scalar, Unidoc.Scalar), to length:Int) -> [Unidoc.Scalar]
    {
        self.expand(vector.0, to: length - 1) + [vector.1]
    }
    func expand(_ scalar:Unidoc.Scalar, to length:Int) -> [Unidoc.Scalar]
    {
        var current:Unidoc.Scalar = scalar
        var path:[Unidoc.Scalar] = [current]
        //  This prevents us from getting stuck in an infinite loop if one of the
        //  documentation archives is malformed/malicious.
        var seen:Set<Unidoc.Scalar> = [current]

        for _:Int in 1 ..< max(1, length)
        {
            guard
            let next:Unidoc.Scalar = self[current.package]?.ancestor(of: current),
            case nil = seen.update(with: next)
            else
            {
                break
            }

            path.append(next)
            current = next
        }

        return path.reversed()
    }
    /// This function looks very similar to `expand(_:to:)`, but it never includes the module
    /// namespace!
    func expand(_ scalar:Unidoc.Scalar) -> [Unidoc.Scalar]
    {
        var current:Unidoc.Scalar = scalar
        var path:[Unidoc.Scalar] = [current]
        var seen:Set<Unidoc.Scalar> = [current]

        while let next:Unidoc.Scalar = self[current.package]?.scope(of: current),
            case nil = seen.update(with: next)
        {

            path.append(next)
            current = next
        }

        return path.reversed()
    }
}
extension Unidoc.Linker
{
    private
    func boundaries(pinned:[Unidoc.Edition?]) -> [Unidoc.Mesh.Boundary]
    {
        var boundaries:[Unidoc.Mesh.Boundary] = []
            boundaries.reserveCapacity(self.current.metadata.dependencies.count + 1)

        if  self.current.metadata.package.name != .swift,
            let swift:Graph = self[.swift]
        {
            boundaries.append(.init(
                targetABI: swift.scalars.hash,
                target: .init(exonym: .swift,
                    requirement: nil,
                    resolution: nil,
                    pin: .linked(swift.id))))
        }
        for (id, dependency):(Unidoc.Edition?, SymbolGraphMetadata.Dependency) in zip(pinned,
            self.current.metadata.dependencies)
        {
            let pinABI:MD5?
            let pin:Unidoc.VolumeMetadata.DependencyPin?

            if  let graph:Graph = self[dependency.package.name]
            {
                pinABI = graph.scalars.hash
                pin = .linked(graph.id)
            }
            else if
                let id:Unidoc.Edition
            {
                pinABI = nil
                pin = .pinned(id)
            }
            else
            {
                pinABI = nil
                pin = nil
            }

            boundaries.append(.init(
                targetABI: pinABI,
                target: .init(exonym: dependency.package.name,
                    requirement: dependency.requirement,
                    resolution: dependency.version.release,
                    pin: pin)))
        }

        return boundaries
    }
}
extension Unidoc.Linker
{
    mutating
    func link(article:SymbolGraph.Article) -> (Unidoc.Passage?, Unidoc.Passage?)
    {
        let outlines:[Unidoc.Outline] = article.outlines.map { self.expand($0) }

        let overview:Unidoc.Passage? = article.overview.isEmpty ? nil : .init(
            outlines: .init(outlines[..<article.fold]),
            markdown: article.overview)
        let details:Unidoc.Passage? = article.details.isEmpty ? nil : .init(
            outlines: .init(outlines[article.fold...]),
            markdown: article.details)

        return (overview, details)
    }

    private mutating
    func expand(_ outline:SymbolGraph.Outline) -> Unidoc.Outline
    {
        switch outline
        {
        case .fragment(let fragment):
            return .fragment(fragment)

        case .location(let location):
            //  File references never cross packages, so this is basically a no-op.
            let line:Int? = location.position == .zero ? nil : location.position.line
            return .bare(line: line, self.current.id + location.file)

        case .symbol(let id):
            guard let id:Unidoc.Scalar = self.current.scalars.decls[id]
            else
            {
                return .fallback(nil)
            }

            return .bare(line: nil, id)

        case .vertex(let id, text: let text):
            if  case SymbolGraph.Plane.decl? = .of(id),
                let id:Unidoc.Scalar = self.current.scalars.decls[id]
            {
                return .path(text, self.expand(id, to: text.words))
            }
            else if
                let namespace:Int = id / .module,
                let id:Unidoc.Scalar = self.current.scalars.modules[namespace]
            {
                return .path(text, [id])
            }
            else
            {
                return .path(text, [self.current.id + id])
            }

        case .vector(let feature, self: let heir, text: let text):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature],
                let heir:Unidoc.Scalar = self.current.scalars.decls[heir]
            {
                return .path(text, self.expand((heir, feature), to: text.words))
            }

        case .unresolved(let unresolved):
            //  In ABI version 0.10 and newer, we should only ever see URLs here.
            switch unresolved.type
            {
            case .doc:  return .fallback("<unreachable>")
            case .ucf:  return .fallback("<unreachable>")
            case .url:  return .url(sanitizing: unresolved.link)
            }
        }

        return .fallback("<unavailable>")
    }
}
extension Unidoc.Linker
{
    func sort<Decl, Priority>(_ decls:consuming [Decl], by _:Priority.Type) -> [Decl]
        where Decl:Identifiable<Unidoc.Scalar>, Priority:Unidoc.SortPriority
    {
        decls.sort
        {
            switch (Priority.of(decl: $0.id, in: self), Priority.of(decl: $1.id, in: self))
            {
            case (nil, nil):        $0.id < $1.id
            case (nil,  _?):        true
            case ( _?, nil):        false
            case (let a?, let b?):  a  <  b
            }
        }

        return decls
    }
}
