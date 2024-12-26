import JSON
import SourceDiagnostics
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc
{
    struct LinkerTables
    {
        private(set)
        var linker:LinkerContext

        /// A table mapping vertices to topics or autogroups.
        private
        var group:[Int32: Group]
        private
        var peers:[Int32: Group]

        private
        var next:Next

        private(set)
        var extensions:LinkerTable<Extension>
        private(set)
        var groups:Mesh.Groups

        private
        init(linker:consuming LinkerContext, next:Next)
        {
            self.linker = linker

            self.group = [:]
            self.peers = [:]

            self.next = next

            self.extensions = [:]
            self.groups = .init()
        }
    }
}
extension Unidoc.LinkerTables
{
    init(linker:consuming Unidoc.LinkerContext)
    {
        let next:Next = .init(base: linker.current.id)
        self.init(linker: linker, next: next)
        self.readExtensions()
    }
}
extension Unidoc.LinkerTables
{
    var current:Unidoc.LinkableGraph { self.linker.current }

    private
    var modules:ModuleView
    {
        .init(namespaces: self.current.namespaces,
            cultures: self.current.cultures,
            edition: self.current.id)
    }

    private mutating
    func readExtensions()
    {
        for local:Int32 in self.current.decls.nodes.indices
        {
            let node:SymbolGraph.DeclNode = self.current.decls.nodes[local]
            if  node.extensions.isEmpty
            {
                continue
            }

            guard
            let extendee:Unidoc.Scalar = self.linker.current.scalars.decls[local]
            else
            {
                let symbol:Symbol.Decl = self.linker.current.decls.symbols[local]
                self.linker.diagnostics[nil] = DroppedExtensionsError.extending(symbol,
                    count: node.extensions.count)
                continue
            }

            self.extensions.add(extensions: node.extensions,
                extending: extendee,
                context: &self.linker)
        }

        self.peers = self.extensions.peers(in: self.linker.current.id)
    }
}
extension Unidoc.LinkerTables
{
    borrowing
    func linkConformingTypes() -> Unidoc.LinkerTable<Unidoc.Conformers>
    {
        var conformingTypes:Unidoc.LinkerTable<Unidoc.Conformers> = [:]

        for (id, `extension`):(Unidoc.ExtensionSignature, Unidoc.Extension) in self.extensions
        {
            guard
            let extendedType:SymbolGraph.Decl = self.linker[decl: id.extendee]
            else
            {
                continue
            }
            /// A lot of C types have `Equatable` and `Hashable` conformances, but we don’t
            /// care about them.
            guard case .swift = extendedType.language
            else
            {
                continue
            }
            for conformance:Unidoc.Scalar in `extension`.conformances
            {
                conformingTypes[.conforms(to: conformance, in: id.culture)].append(
                    conformer: id.extendee,
                    where: id.conditions.constraints)
            }
        }

        return conformingTypes
    }

    /// This **must** be called before ``linkCultures``!
    mutating
    func linkProducts() -> [Unidoc.ProductVertex]
    {
        var productVertices:[Unidoc.ProductVertex] = []
            productVertices.reserveCapacity(self.current.metadata.products.count)

        //  Create a synthetic topic containing all the products. This will become a “See Also”
        //  for their product pages.
        var products:Unidoc.CuratorGroup = .init(id: self.next(.curator),
            scope: self.current.id.global)

        for (p, product):(Int32, SymbolGraph.Product) in zip(
            self.current.metadata.products.indices,
            self.current.metadata.products)
        {
            var constituents:[Unidoc.Scalar] = product.cultures
                .sorted
            {
                self.current.namespaces[$0] < self.current.namespaces[$1]
            }
                .map
            {
                self.current.id + $0
            }

            for product:Symbol.Product in product.dependencies.sorted()
            {
                if  let package:Unidoc.LinkableGraph = self.linker[product.package],
                    let q:Unidoc.Scalar = package.scalars.products[product.name]
                {
                    constituents.append(q)
                }
            }

            let product:Unidoc.ProductVertex = .init(id: self.current.id + p,
                constituents: constituents,
                symbol: product.name,
                type: product.type,
                group: products.id)

            products.items.append(product.id)
            productVertices.append(product)
        }

        //  Create a synthetic topic containing all the cultures. This will become a “See Also”
        //  for their module pages, unless they belong to a custom topic group.
        let cultures:Unidoc.CuratorGroup = .init(id: self.next(.curator),
            scope: self.current.id.global,
            items: self.current.cultures.indices.sorted
            {
                self.current.namespaces[$0] <
                self.current.namespaces[$1]
            }
                .map
            {
                self.current.id + $0
            })

        self.groups.curators.append(products)
        self.groups.curators.append(cultures)

        for c:Int in self.current.cultures.indices
        {
            self.group[c * .module] = cultures.id
        }

        return productVertices
    }

    mutating
    func linkCurations()
    {
        for topic:[Int32] in self.current.curation
        {
            let items:[Unidoc.Scalar] = topic.compactMap
            {
                //  This is needed to correctly handle the case where a topic contains a
                //  reference to a feature inherited from a different package.
                if  case SymbolGraph.Plane.decl? = .of($0)
                {
                    self.current.scalars.decls[$0]
                }
                else if
                    let c:Int = $0 / .module
                {
                    self.current.scalars.modules[c]
                }
                else
                {
                    self.current.id + $0
                }
            }
            if  items.isEmpty
            {
                continue
            }
            let group:Unidoc.CuratorGroup = .init(id: self.next(.curator), items: items)
            for item:Int32 in topic
            {
                //  TODO: diagnose overlapping topics
                self.group[item] = group.id
            }

            self.groups.curators.append(group)
        }
    }
    mutating
    func linkIntrinsics()
    {
        for module:ModuleContext in self.modules
        {
            for decls:SymbolGraph.Namespace in module.culture.namespaces
            {
                for (d, node):(Int32, SymbolGraph.DeclNode) in zip(decls.range,
                    self.current.decls.nodes[decls.range])
                {
                    //  Should always succeed!
                    guard
                    let owner:Unidoc.Scalar = self.current.scalars.decls[d],
                    let decl:SymbolGraph.Decl = node.decl
                    else
                    {
                        continue
                    }

                    let intrinsicGroup:Unidoc.Group = self.next(.intrinsic)
                    let intrinsicCount:Int = decl.requirements.count + decl.inhabitants.count
                    var intrinsicMembers:[Unidoc.Scalar] = []
                        intrinsicMembers.reserveCapacity(intrinsicCount)

                    //  https://forums.swift.org/t/efficiently-chaining-two-arrays/69551
                    for local:Int32 in [decl.requirements, decl.inhabitants].joined()
                    {
                        //  This should always succeed, since requirements and inhabitants
                        //  should appear in the same package (and the same module!) as the
                        //  protocol/enum that declares them.
                        guard
                        let id:Unidoc.Scalar = self.current.scalars.decls[local]
                        else
                        {
                            continue
                        }

                        self.peers[local] = intrinsicGroup
                        intrinsicMembers.append(id)
                    }

                    if !intrinsicMembers.isEmpty
                    {
                        self.groups.intrinsics.append(.init(id: intrinsicGroup,
                            culture: module.id,
                            scope: owner,
                            items: self.linker.sort(intrinsicMembers,
                                by: Unidoc.SemanticPriority.self)))
                    }
                }
            }
        }
    }

    /// This **must** be called after ``linkProducts``!
    mutating
    func linkArticles() -> [Unidoc.ArticleVertex]
    {
        self.modules.reduce(into: [])
        {
            if  let range:ClosedRange<Int32> = $1.culture.articles
            {
                for local:Int32 in range
                {
                    $0.append(self.linkArticle(at: local, under: $1))
                }
            }
        }
    }

    mutating
    func linkDecls() -> [Unidoc.DeclVertex]
    {
        self.modules.reduce(into: [])
        {
            var miscellaneous:[Unidoc.Scalar] = []

            //  Create decl records.
            for colony:SymbolGraph.Namespace in $1.culture.namespaces
            {
                let name:Symbol.Module = self.current.namespaces[colony.index]

                guard
                let id:Unidoc.Scalar = self.current.scalars.modules[colony.index]
                else
                {
                    self.linker.diagnostics[nil] = DroppedExtensionsError.extending(name,
                        count: colony.range.count)
                    continue
                }

                let namespace:ModuleNamespace = .init(
                    culture: $1.id,
                    colony: id,
                    symbol: name)

                for local:Int32 in colony.range
                {
                    guard
                    let vertex:Unidoc.DeclVertex = self.linkDecl(at: local, under: namespace)
                    else
                    {
                        continue
                    }

                    if  case nil = vertex.group,
                        vertex.scope.isEmpty,
                        vertex.symbol.language == .s || vertex.phylum.isTypelike
                    {
                        miscellaneous.append(vertex.id)
                    }

                    $0.append(vertex)
                }
            }

            if !miscellaneous.isEmpty
            {
                //  Create top-level polygon.
                self.groups.curators.append(.init(id: self.next(.curator),
                    scope: $1.id,
                    items: self.linker.sort(miscellaneous, by: Unidoc.SemanticPriority.self)))
            }
        }
    }
    mutating
    func linkCultures() -> [Unidoc.CultureVertex]
    {
        self.modules.map
        {
            var vertex:Unidoc.CultureVertex = .init(id: $0.id,
                module: $0.culture.module,
                group: $0.culture.article?.footer == .omit
                    ? nil
                    : self.group[$0.id.citizen])

            if  let article:SymbolGraph.Article = $0.culture.article
            {
                //  No sense customizing the headline if there is no article.
                vertex.headline = $0.culture.headline
                vertex.readme = article.file.map { self.current.id + $0 }
                (vertex.overview, vertex.details) = self.linker.link(article: article)
            }

            return vertex
        }
    }

    func linkRedirects() -> [Unidoc.RedirectVertex]
    {
        self.modules.reduce(into: [])
        {
            for (decls, hashed):([Int32], Bool) in [
                ($1.culture.reexports.unhashed, false),
                ($1.culture.reexports.hashed, true),
            ]
            {
                for target:Int32 in decls
                {
                    if  let vertex:Unidoc.RedirectVertex = self.linkRedirect(
                        target: target,
                        hashed: hashed,
                        from: $1.symbol)
                    {
                        $0.append(vertex)
                    }
                }
            }
        }
    }

    private
    func linkRedirect(
        target local:Int32,
        hashed:Bool,
        from namespace:Symbol.Module) -> Unidoc.RedirectVertex?
    {
        let symbol:Symbol.Decl = self.current.decls.symbols[local]

        guard
        let id:Unidoc.Scalar = self.current.scalars.decls[local],
        let decl:SymbolGraph.Decl = self.linker[decl: id]
        else
        {
            return nil
        }

        return .init(id: .init(volume: self.current.id,
                stem: .decl(namespace, decl.path, decl.phylum),
                hash: .decl(symbol)),
            target: id,
            hashed: hashed)
    }
}
extension Unidoc.LinkerTables
{
    private mutating
    func linkArticle(at local:Int32, under namespace:ModuleContext) -> Unidoc.ArticleVertex
    {
        let node:SymbolGraph.ArticleNode = self.current.articles.nodes[local]
        let symbol:Symbol.Article = self.current.articles.symbols[local]
        let id:Unidoc.Scalar = self.current.id + local
        /// >   Note:
        /// Constructing the stem by joining the `namespace.symbol` with the `symbol.path`
        /// should result in the same stem that you would obtain by just copying the raw
        /// article symbol itself, because articles should never migrate between modules.
        /// However, we tend to emphasize the distinction between module culture and module
        /// namespace elsewhere, so we will continue to construct the stem pedantically.
        var vertex:Unidoc.ArticleVertex = .init(id: id,
            stem: .article(namespace.symbol, path: symbol.path),
            culture: namespace.id,
            readme: node.article.file.map { self.current.id + $0 },
            headline: node.headline,
            group: node.article.footer == .omit ? nil : self.group[local])

        (vertex.overview, vertex.details) = self.linker.link(article: node.article)

        return vertex
    }

    /// Returns a list of uncategorized top-level declarations.
    private mutating
    func linkDecl(at local:Int32, under namespace:ModuleNamespace) -> Unidoc.DeclVertex?
    {
        let symbol:Symbol.Decl = self.current.decls.symbols[local]
        let node:SymbolGraph.DeclNode = self.current.decls.nodes[local]

        /// Does this declaration belong to a topic?
        let group:Unidoc.Group? = node.decl?.article?.footer == .omit ? nil : self.group[local]
        /// Does this declaration have peers?
        let peers:Unidoc.Group? = self.peers[local]
        /// Is this declaration a top-level member of its module?
        /// (Being a top-level declaration is the only way this can be nil)
        let scope:Unidoc.Scalar? = self.current.scope(of: local)

        //  Ceremonial unwraps, should always succeed since we are only iterating
        //  over module ranges.
        guard
        let decl:SymbolGraph.Decl = node.decl,
        let id:Unidoc.Scalar = self.current.scalars.decls[local]
        else
        {
            return nil
        }

        let superforms:[Unidoc.Scalar] = decl.superforms.compactMap
        {
            self.current.scalars.decls[$0]
        }
        for s:Unidoc.Scalar in superforms
        {
            let unconditional:Unidoc.ExtensionConditions = .init(constraints: [],
                culture: namespace.cultureOffset)

            self.extensions[.extends(s, where: unconditional)].subforms.append(id)
        }

        var vertex:Unidoc.DeclVertex = .init(id: id,
            flags: .init(
                language: decl.language,
                phylum: decl.phylum,
                kinks: decl.kinks,
                route: decl.route),
            signature: decl.signature.map { self.current.scalars.decls[$0] },
            symbol: symbol,
            stem: .decl(namespace.symbol, decl.path, decl.phylum),
            _requirements: [],
            superforms: self.linker.sort(superforms, by: Unidoc.SemanticPriority.self),
            namespace: namespace.colony,
            culture: namespace.culture,
            scope: scope.map { self.linker.expand($0) } ?? [],
            renamed: decl.renamed.map { self.current.scalars.decls[$0] } ?? nil,
            file: decl.location.map { self.current.id + $0.file },
            position: decl.location?.position,
            peers: peers,
            group: group)

        if  let article:SymbolGraph.Article = decl.article
        {
            (vertex.overview, vertex.details) = self.linker.link(article: article)
            vertex.readme = article.file.map { self.current.id + $0 }
        }

        return vertex
    }
}
