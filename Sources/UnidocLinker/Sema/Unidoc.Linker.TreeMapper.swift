import JSON
import MarkdownRendering
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc.Linker
{
    struct TreeMapper:~Copyable
    {
        /// Caches foreign shoots, as it is non-trivial to discover the namespace of a foreign
        /// declaration.
        private
        var foreign:[Unidoc.Scalar: (Unidoc.Shoot, Phylum.DeclFlags)]
        /// Caches local shoots, as it is non-trivial to lookup already-linked vertices by
        /// scalar.
        private
        var local:[Unidoc.Scalar: (Unidoc.Shoot, Phylum.DeclFlags)]

        /// Maps cultures to trees.
        private
        var trees:[Unidoc.Scalar: TreeMembers]

        init(zone:Unidoc.Edition)
        {
            self.foreign = [:]
            self.local = [:]
            self.trees = [:]
        }
    }
}
extension Unidoc.Linker.TreeMapper
{
    mutating
    func add(_ vertex:Unidoc.ArticleVertex)
    {
        self.trees[vertex.culture, default: []].articles.append(.init(
            shoot: vertex.shoot,
            type: .text("\(vertex.headline.safe)")))
    }
    mutating
    func add(_ vertex:Unidoc.DeclVertex)
    {
        self.local[vertex.id] = (vertex.shoot, vertex.flags)

        var flags:Flags?
        {
            if !vertex.signature.availability.isGenerallyRecommended
            {
                return .deprecated
            }
            else if case _? = vertex.signature.spis
            {
                return .spi
            }
            else
            {
                return nil
            }
        }

        switch vertex.phylum
        {
        case .actor, .class, .struct, .enum, .protocol, .macro(.attached):
            self.trees[vertex.culture, default: []].types[vertex.shoot] =
                (.culture, vertex.flags)

        case .typealias:
            //  Typealiases show up in search, but not in the type tree. Typealiases are often
            //  deprecated, and disappear from signatures. That’s why people search for them.
            fallthrough

        case .associatedtype, .case, .func, .macro(.freestanding), .var:
            //  Don’t include C declarations in search.
            if  vertex.flags.cdecl
            {
                break
            }

            self.trees[vertex.culture, default: []].extra.append((vertex.shoot, flags))

        case .operator, .deinitializer, .initializer, .subscript:
            //  These all look the same, so they probably wouldn’t be very useful in search.
            break
        }
    }
}
extension Unidoc.Linker.TreeMapper
{
    mutating
    func register(foreign:Unidoc.Scalar,
        with context:borrowing Unidoc.Linker,
        as index:Int) -> Unidoc.ForeignVertex?
    {
        if  case nil = self.local[foreign]
        {
            {
                if  case nil = $0
                {
                    let vertex:Unidoc.ForeignVertex = Self.create(foreign: foreign,
                        with: context,
                        as: index)
                    $0 = (vertex.shoot, vertex.flags)
                    return vertex
                }
                else
                {
                    return nil
                }
            } (&self.foreign[foreign])
        }
        else
        {
            nil
        }
    }

    private static
    func create(foreign:Unidoc.Scalar,
        with context:borrowing Unidoc.Linker,
        as index:Int) -> Unidoc.ForeignVertex
    {
        guard
        let snapshot:Unidoc.Linker.Graph = context[foreign.package]
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
                \(snapshot.metadata.package.name)!
                """)
        }

        let symbol:Symbol.Decl = snapshot.decls.symbols[node]
        /// Our policy for hashing out-of-package types is to hash if the type uses a
        /// hash suffix in its home package, even if the type would not require any
        /// disambiguation in this package.
        return .init(id: context.current.id + index * .foreign,
            extendee: foreign,
            scope: snapshot.scope(of: node).map { context.expand($0) } ?? [],
            flags: .init(
                language: decl.language,
                phylum: decl.phylum,
                kinks: decl.kinks,
                route: decl.route),
            stem: .decl(namespace, decl.path, orientation: decl.phylum.orientation),
            hash: .decl(symbol))
    }
}
extension Unidoc.Linker.TreeMapper
{
    mutating
    func update(with group:Unidoc.ExtensionGroup)
    {
        let tree:Unidoc.Scalar = group.culture

        if  let (shoot, flags):(Unidoc.Shoot, Phylum.DeclFlags) = self.local[group.scope]
        {
            { _ in }(&self.trees[tree, default: []].types[shoot, default: (.package, flags)])
        }
        else if
            let (shoot, flags):(Unidoc.Shoot, Phylum.DeclFlags) = self.foreign[group.scope]
        {
            { _ in }(&self.trees[tree, default: []].types[shoot, default: (.foreign, flags)])
        }
    }
}
extension Unidoc.Linker.TreeMapper
{
    consuming
    func build(cultures:[Unidoc.CultureVertex]) -> (trees:[Unidoc.TypeTree], index:JSON)
    {
        let cultures:[Unidoc.Scalar: Symbol.Module] = cultures.reduce(into: [:])
        {
            $0[$1.id] = $1.module.id
        }

        var trees:[Unidoc.TypeTree] = []
            trees.reserveCapacity(self.trees.count)

        let json:JSON = .array
        {
            for (id, members):(Unidoc.Scalar, Unidoc.Linker.TreeMembers) in self.trees.sorted(
                by: { $0.key < $1.key })
            {
                guard
                let culture:Symbol.Module = cultures[id]
                else
                {
                    continue
                }

                var tree:Unidoc.TypeTree = .init(id: id)

                tree.rows += members.articles.sorted
                {
                    $0.type.text ?? "" < $1.type.text ?? ""
                }

                tree.rows += members.types.map
                {
                    .init(shoot: $0.key, type: .stem($0.value.0, $0.value.1))
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
                        for noun:Unidoc.Noun in tree.rows
                        {
                            if  case .stem(let citizenship, _) = noun.type,
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
                        for (shoot, flags):(Unidoc.Shoot, Flags?) in members.extra
                        {
                            $0[+, Any.self]
                            {
                                $0["s"] = shoot.stem.rawValue
                                $0["h"] = shoot.hash?.value
                                $0["f"] = flags
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
