import JSON
import MarkdownRendering
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension DynamicLinker
{
    struct TreeMapper:~Copyable
    {
        /// Caches foreign shoots, as it is non-trivial to discover the namespace of a foreign
        /// declaration.
        private
        var foreign:[Unidoc.Scalar: Volume.Shoot]
        /// Caches local shoots, as it is non-trivial to lookup already-linked vertices by
        /// scalar.
        private
        var local:[Unidoc.Scalar: Volume.Shoot]

        /// Maps cultures to trees.
        private
        var trees:[Unidoc.Scalar: TreeMembers]

        private
        var next:Unidoc.Counter<UnidocPlane.Foreign>

        init(zone:Unidoc.Edition)
        {
            self.foreign = [:]
            self.local = [:]
            self.trees = [:]

            self.next = .init(zone: zone)
        }
    }
}
extension DynamicLinker.TreeMapper
{
    mutating
    func add(_ vertex:Volume.Vertex.Article)
    {
        self.local[vertex.id] = vertex.shoot
        self.trees[vertex.culture, default: []].articles.append(.init(shoot: vertex.shoot,
            style: .text("\(vertex.headline.safe)")))
    }
    mutating
    func add(_ vertex:Volume.Vertex.Decl)
    {
        self.local[vertex.id] = vertex.shoot

        switch vertex.phylum
        {
        case .actor, .class, .struct, .enum, .protocol, .macro(.attached):
            self.trees[vertex.culture, default: []].types[vertex.shoot] = .culture

        case .func(nil), .var(nil), .macro(.freestanding):
            //  Global procedures show up in search, but not in the type tree.
            self.trees[vertex.culture, default: []].procs.append(vertex.shoot)

        case _:
            return
        }
    }
}
extension DynamicLinker.TreeMapper
{
    mutating
    func register(foreign:Unidoc.Scalar,
        with context:borrowing DynamicLinker) -> Volume.Vertex.Foreign
    {
        guard
        let snapshot:DynamicLinker.Snapshot = context[foreign.package]
        else
        {
            fatalError("scalar \(foreign) is not from a package in this context!")
        }
        guard
        let namespace:Symbol.Module = snapshot.namespace(of: foreign),
        let node:Int32 = foreign - snapshot.id,
        let decl:SymbolGraph.Decl = snapshot.decls.nodes[node].decl
        else
        {
            fatalError("""
                scalar \(foreign) is either not a decl, or not from \
                \(snapshot.metadata.package)!
                """)
        }

        let symbol:Symbol.Decl = snapshot.decls.symbols[node]
        /// Our policy for hashing out-of-package types is to hash if the type uses a
        /// hash suffix in its home package, even if the type would not require any
        /// disambiguation in this package.
        let vertex:Volume.Vertex.Foreign = .init(id: self.next.id(),
            extendee: foreign,
            scope: snapshot.scope(of: node).map { context.expand($0) } ?? [],
            flags: .init(
                phylum: decl.phylum,
                kinks: decl.kinks,
                route: decl.route),
            stem: .init(namespace, decl.path, orientation: decl.phylum.orientation),
            hash: .init(hashing: "\(symbol)"))

        self.foreign[foreign] = vertex.shoot

        return vertex
    }
}
extension DynamicLinker.TreeMapper
{
    mutating
    func update(with group:Volume.Group.Extension)
    {
        if  let shoot:Volume.Shoot = self.local[group.scope]
        {
            { _ in }(&self.trees[group.culture, default: []].types[shoot, default: .package])
        }
        else if
            let shoot:Volume.Shoot = self.foreign[group.scope]
        {
            { _ in }(&self.trees[group.culture, default: []].types[shoot, default: .foreign])
        }
    }
}
extension DynamicLinker.TreeMapper
{
    consuming
    func build(cultures:[Volume.Vertex.Culture]) -> (trees:[Volume.TypeTree], index:JSON)
    {
        let cultures:[Unidoc.Scalar: Symbol.Module] = cultures.reduce(into: [:])
        {
            $0[$1.id] = $1.module.id
        }

        var trees:[Volume.TypeTree] = []
            trees.reserveCapacity(self.trees.count)

        let json:JSON = .array
        {
            for (id, members):(Unidoc.Scalar, DynamicLinker.TreeMembers) in self.trees.sorted(
                by: { $0.key < $1.key })
            {
                guard
                let culture:Symbol.Module = cultures[id]
                else
                {
                    continue
                }

                var tree:Volume.TypeTree = .init(id: id)

                tree.rows += members.articles.sorted
                {
                    $0.style < $1.style
                }

                tree.rows += members.types.map
                {
                    .init(shoot: $0.key, style: .stem($0.value))
                }
                    .sorted
                {
                    $0.shoot < $1.shoot
                }

                $0[+, Any.self]
                {
                    $0["c"] = "\(culture)"
                    $0["n"]
                    {
                        for noun:Volume.Noun in tree.rows
                        {
                            if  case .stem(let citizenship) = noun.style,
                                citizenship != .culture
                            {
                                continue
                            }

                            $0[+, Any.self]
                            {
                                $0["s"] = noun.shoot.stem.rawValue
                                $0["h"] = noun.shoot.hash?.value
                            }
                        }
                        for shoot:Volume.Shoot in members.procs
                        {
                            $0[+, Any.self]
                            {
                                $0["s"] = shoot.stem.rawValue
                                $0["h"] = shoot.hash?.value
                            }
                        }
                    }
                }

                trees.append(tree)
            }
        }

        return (trees, json)
    }
}
