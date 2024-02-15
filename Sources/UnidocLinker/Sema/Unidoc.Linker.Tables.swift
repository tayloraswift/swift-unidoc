import CodelinkResolution
import JSON
import SymbolGraphs
import Symbols
import Unidoc
import SourceDiagnostics
import UnidocRecords

extension Unidoc.Linker
{
    //  https://github.com/apple/swift/issues/71606
    struct Tables:~Copyable
    {
        private
        let contexts:[SymbolGraph.ModuleContext]
        private(set)
        var context:Unidoc.Linker

        /// Protocol conformances, including retroactive conformances, for each citizen or
        /// extended declaration in the **current** snapshot.
        ///
        /// The listed protocols can be protocols in the current snapshot, or protocols from
        /// upstream dependencies, like the standard library. However, the lists only include
        /// conformances that were declared by at least one of the current snapshot’s cultures.
        private
        let conformances:SymbolGraph.Table<SymbolGraph.DeclPlane, Unidoc.ConformanceList>

        /// A table mapping vertices to topics or autogroups.
        private
        var group:[Int32: Unidoc.Group]
        private
        var peers:[Int32: Unidoc.Group]

        private
        var next:Next

        private(set)
        var extensions:Unidoc.Linker.Table<Unidoc.Extension>
        var articles:[Unidoc.ArticleVertex]
        var decls:[Unidoc.DeclVertex]

        var groups:Unidoc.Volume.Groups

        private
        init(
            contexts:consuming [SymbolGraph.ModuleContext],
            context:consuming Unidoc.Linker,
            conformances:SymbolGraph.Table<SymbolGraph.DeclPlane, Unidoc.ConformanceList>,
            extensions:Unidoc.Linker.Table<Unidoc.Extension>)
        {
            self.contexts = contexts
            self.context = context

            self.conformances = conformances

            self.group = [:]
            self.peers = extensions.peers(in: self.context.current.id)

            self.next = .init(base: self.context.current.id)

            self.extensions = extensions
            self.articles = []
            self.decls = []

            self.groups = .init()
        }
    }
}
extension Unidoc.Linker.Tables
{
    init(context:consuming Unidoc.Linker)
    {
        let modules:[SymbolGraph.ModuleContext] = context.modules()

        var extensions:Unidoc.Linker.Table<Unidoc.Extension> = [:]

        let conformances:SymbolGraph.Table<SymbolGraph.DeclPlane, Unidoc.ConformanceList> =
            context.current.decls.nodes.map
        {
            $1.extensions.isEmpty ? [:] : extensions.add($1.extensions,
                extending: $0,
                modules: modules,
                context: &context)
        }

        self.init(
            contexts: modules,
            context: context,
            conformances: conformances,
            extensions: extensions)
    }
}
extension Unidoc.Linker.Tables
{
    var current:Unidoc.Linker.Graph { self.context.current }

    private
    var modules:SymbolGraph.ModuleView
    {
        .init(namespaces: self.current.namespaces,
            cultures: self.current.cultures,
            contexts: self.contexts,
            edition: self.current.id)
    }
}
extension Unidoc.Linker.Tables
{
    borrowing
    func linkConformingTypes() -> Unidoc.Linker.Table<Unidoc.Conformers>
    {
        var types:Unidoc.Linker.Table<Unidoc.Conformers> = [:]

        for (d, conformances):(Int32, Unidoc.ConformanceList) in zip(
            self.current.decls.nodes.indices,
            self.conformances)
        {
            guard
            let d:Unidoc.Scalar = self.current.scalars.decls[d]
            else
            {
                continue
            }

            switch self.context[d.package]?.decls[d.citizen]?.decl?.language
            {
            case .c?, .cpp?:
                continue

            case .swift?, nil:
                types.add(conformances: conformances, of: d)
            }
        }

        return types
    }

    /// This **must** be called before ``linkCultures``!
    mutating
    func linkProducts() -> [Unidoc.ProductVertex]
    {
        var productPolygon:Unidoc.PolygonalGroup = .init(id: self.next(.polygon),
            scope: self.current.id.global)

        var products:[Unidoc.ProductVertex] = []
            products.reserveCapacity(self.current.metadata.products.count)

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
                if  let q:Unidoc.Scalar =
                    self.context[product.package]?.scalars.products[product.name]
                {
                    constituents.append(q)
                }
            }

            let product:Unidoc.ProductVertex = .init(id: self.current.id + p,
                constituents: constituents,
                symbol: product.name,
                type: product.type,
                group: productPolygon.id)

            productPolygon.members.append(product.id)
            products.append(product)
        }

        //  Create a synthetic topic containing all the products. This will become a “See Also”
        //  for their product pages.

        //  Create a synthetic topic containing all the cultures. This will become a “See Also”
        //  for their module pages, unless they belong to a custom topic group.
        let culturePolygon:Unidoc.PolygonalGroup = .init(id: self.next(.polygon),
            scope: self.current.id.global,
            members: self.current.cultures.indices.sorted
            {
                self.current.namespaces[$0] <
                self.current.namespaces[$1]
            }
            .map
            {
                self.current.id + $0
            })

        self.groups.polygons.append(productPolygon)
        self.groups.polygons.append(culturePolygon)

        for c:Int in self.current.cultures.indices
        {
            self.group[c * .module] = culturePolygon.id
        }

        return products
    }

    /// This **must** be called after ``linkProducts``!
    mutating
    func linkCultures() -> [Unidoc.CultureVertex]
    {
        //  First pass to create the topic records, which also populates topic memberships.
        for (namespace, culture):(SymbolGraph.NamespaceContext<Void>, SymbolGraph.Culture) in
            self.modules
        {
            //  Create topic records for the culture.
            self.link(topics: culture.topics, under: namespace, owner: namespace.culture)

            //  Create topic records for the decls.
            for decls:SymbolGraph.Namespace in culture.namespaces
            {
                let namespace:SymbolGraph.NamespaceContext<Void> = .init(
                    context: namespace.context,
                    culture: namespace.culture,
                    module: self.current.namespaces[decls.index])

                for (d, (node, conformances)):
                    (Int32, (SymbolGraph.DeclNode, Unidoc.ConformanceList)) in zip(
                    decls.range,
                    zip(self.current.decls.nodes[decls.range],
                        self.conformances[decls.range]))
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
                    var intrinsicMembers:[Unidoc.Scalar] = []
                        intrinsicMembers.reserveCapacity(decl.requirements.count)
                    //  https://forums.swift.org/t/efficiently-chaining-two-arrays/69551
                    for requirement:Int32 in decl.requirements
                    {
                        //  This should always succeed, since requirements should appear in
                        //  the same package (and the same module!) as the protocol that
                        //  declares them.
                        guard
                        let r:Unidoc.Scalar = self.current.scalars.decls[requirement]
                        else
                        {
                            continue
                        }

                        self.peers[requirement] = intrinsicGroup
                        intrinsicMembers.append(r)
                    }
                    for inhabitant:Int32 in decl.inhabitants
                    {
                        guard
                        let i:Unidoc.Scalar = self.current.scalars.decls[inhabitant]
                        else
                        {
                            continue
                        }

                        self.peers[inhabitant] = intrinsicGroup
                        intrinsicMembers.append(i)
                    }

                    if !intrinsicMembers.isEmpty
                    {
                        self.groups.intrinsics.append(.init(id: intrinsicGroup,
                            culture: namespace.culture,
                            scope: owner,
                            members: self.context.sort(intrinsicMembers,
                                by: Unidoc.SemanticPriority.self)))
                    }

                    for f:Int32 in decl.features
                    {
                        //  The feature might have been declared in a different package!
                        guard
                        let f:Unidoc.Scalar = self.current.scalars.decls[f],
                        let p:Unidoc.Scalar = self.context[f.package]?.scope(of: f)
                        else
                        {
                            continue
                        }

                        //  Now that we know the address of the feature’s original protocol,
                        //  we can look up the constraints for the conformance(s) that
                        //  conceived it.
                        //
                        //  This drops the feature if it belongs to a protocol whose
                        //  conformance was not declared by any culture of the current
                        //  package.
                        for conditions:Unidoc.ExtensionConditions in conformances[to: p]
                        {
                            self.extensions[.extends(owner, where: conditions)]
                                .features
                                .append(f)
                        }
                    }

                    //  Optimization
                    if  decl.topics.isEmpty
                    {
                        continue
                    }

                    self.link(topics: decl.topics,
                        under: namespace,
                        scope: decl.scope,
                        owner: owner)
                }
            }
            //  Create topic records for the articles.
            if  let range:ClosedRange<Int32> = culture.articles
            {
                for (a, node):(Int32, SymbolGraph.ArticleNode) in zip(range,
                    self.current.articles.nodes[range])
                {
                    if  node.topics.isEmpty
                    {
                        continue
                    }

                    let owner:Unidoc.Scalar = self.current.id + a

                    self.link(topics: node.topics,
                        under: namespace,
                        owner: owner)
                }
            }
        }

        //  Second pass to create various vertex records, which reads from the ``topics``.
        for (namespace, culture):(SymbolGraph.NamespaceContext<Void>, SymbolGraph.Culture) in
            self.modules
        {
            //  Create decl records.
            for decls:SymbolGraph.Namespace in culture.namespaces
            {
                let module:Symbol.Module = self.current.namespaces[decls.index]

                guard
                let scalar:Unidoc.Scalar = self.current.scalars.modules[decls.index]
                else
                {
                    self.context.diagnostics[nil] = DroppedExtensionsError.extending(module,
                        count: decls.range.count)
                    continue
                }

                let namespace:SymbolGraph.NamespaceContext<Unidoc.Scalar> = .init(
                    context: namespace.context,
                    culture: namespace.culture,
                    module: module,
                    id: scalar)

                let miscellaneous:[Unidoc.Scalar] = self.link(decls: decls.range,
                    under: namespace)

                if  miscellaneous.isEmpty
                {
                    continue
                }

                //  Create top-level polygon.
                self.groups.polygons.append(.init(id: self.next(.polygon),
                    scope: namespace.culture,
                    members: self.context.sort(consume miscellaneous,
                        by: Unidoc.SemanticPriority.self)))
            }
            //  Create article records.
            if  let articles:ClosedRange<Int32> = culture.articles
            {
                self.link(articles: articles, under: namespace)
            }
        }

        return self.modules.map
        {
            self.link(culture: $0.culture, under: $0.namespace)
        }
    }
}
extension Unidoc.Linker.Tables
{
    private mutating
    func link(topics:[SymbolGraph.Topic],
        under namespace:SymbolGraph.NamespaceContext<Void>,
        scope:[String] = [],
        owner:Unidoc.Scalar)
    {
        for topic:SymbolGraph.Topic in topics
        {
            var record:Unidoc.TopicGroup = .init(id: self.next(.topic),
                culture: namespace.culture,
                scope: owner)

            (record.overview, record.members) = self.context.resolving(
                namespace: namespace.module,
                module: namespace.context,
                scope: scope)
            {
                $0.link(topic: topic)
            }

            self.groups.topics.append(record)

            for case .scalar(let member) in record.members
            {
                //  This may replace a synthesized topic.
                if  let local:Int32 = member - self.current.id
                {
                    self.group[local] = record.id
                }
            }
        }
    }
}
extension Unidoc.Linker.Tables
{
    private mutating
    func link(culture:SymbolGraph.Culture,
        under namespace:SymbolGraph.NamespaceContext<Void>) -> Unidoc.CultureVertex
    {
        var vertex:Unidoc.CultureVertex = .init(id: namespace.culture,
            module: culture.module,
            group: self.group[namespace.culture.citizen])

        if  let article:SymbolGraph.Article = culture.article
        {
            vertex.readme = article.file.map { self.current.id + $0 }

            (vertex.overview, vertex.details) = self.context.resolving(
                namespace: namespace.module,
                module: namespace.context)
            {
                $0.link(article: article)
            }
        }

        return vertex
    }

    private mutating
    func link(articles range:ClosedRange<Int32>,
        under namespace:SymbolGraph.NamespaceContext<Void>)
    {
        for (a, node):(Int32, SymbolGraph.ArticleNode) in zip(range,
            self.current.articles.nodes[range])
        {
            let symbol:Symbol.Article = self.current.articles.symbols[a]
            let scalar:Unidoc.Scalar = self.current.id + a
            /// >   Note:
            /// Constructing the stem by joining the `namespace.module` with the `symbol.path`
            /// should result in the same stem that you would obtain by just copying the raw
            /// article symbol itself, because articles should never migrate between modules.
            /// However, we tend to emphasize the distinction between module culture and module
            /// namespace elsewhere, so we will continue to construct the stem pedantically.
            var vertex:Unidoc.ArticleVertex = .init(id: scalar,
                stem: .article(namespace.module, path: symbol.path),
                culture: namespace.culture,
                readme: node.article.file.map { self.current.id + $0 },
                headline: node.headline,
                group: self.group[a])

            (vertex.overview, vertex.details) = self.context.resolving(
                namespace: namespace.module,
                module: namespace.context)
            {
                $0.link(article: node.article)
            }

            self.articles.append(vertex)
        }
    }

    /// Returns a list of uncategorized top-level declarations.
    private mutating
    func link(decls range:ClosedRange<Int32>,
        under namespace:SymbolGraph.NamespaceContext<Unidoc.Scalar>) -> [Unidoc.Scalar]
    {
        var miscellaneous:[Unidoc.Scalar] = []

        for (d, (symbol, node)):
            (Int32, (Symbol.Decl, SymbolGraph.DeclNode)) in zip(range, zip(
            self.current.decls.symbols[range],
            self.current.decls.nodes[range]))
        {
            /// Is this declaration a member of a topic?
            let group:Unidoc.Group? = self.group[d]
            /// Is this declaration have peers?
            let peers:Unidoc.Group? = self.peers[d]
            /// Is this declaration a top-level member of its module?
            /// (Being a top-level declaration is the only way this can be nil.)
            let scope:Unidoc.Scalar? = self.current.scope(of: d)

            //  Ceremonial unwraps, should always succeed since we are only iterating
            //  over module ranges.
            guard
            let decl:SymbolGraph.Decl = node.decl,
            let d:Unidoc.Scalar = self.current.scalars.decls[d]
            else
            {
                continue
            }

            if  case nil = group,
                case nil = scope,
                // needed to avoid vacuuming up default implementations
                decl.path.count == 1,
                // only display swift declarations, or sufficiently typelike c declarations
                symbol.language == .s || decl.phylum.isTypelike
            {
                miscellaneous.append(d)
            }

            let superforms:[Unidoc.Scalar] = decl.superforms.compactMap
            {
                self.current.scalars.decls[$0]
            }
            for s:Unidoc.Scalar in superforms
            {
                let unconditional:Unidoc.ExtensionConditions = .init(constraints: [],
                    culture: namespace.c)

                self.extensions[.extends(s, where: unconditional)].subforms.append(d)
            }

            var vertex:Unidoc.DeclVertex = .init(id: d,
                flags: .init(
                    language: decl.language,
                    phylum: decl.phylum,
                    kinks: decl.kinks,
                    route: decl.route),
                signature: decl.signature.map { self.current.scalars.decls[$0] },
                symbol: symbol,
                stem: .decl(namespace.module, decl.path, orientation: decl.phylum.orientation),
                _requirements: [],
                superforms: self.context.sort(superforms, by: Unidoc.SemanticPriority.self),
                namespace: namespace.id,
                culture: namespace.culture,
                scope: scope.map { self.context.expand($0) } ?? [],
                renamed: decl.renamed.map { self.current.scalars.decls[$0] } ?? nil,
                file: decl.location.map { self.current.id + $0.file },
                position: decl.location?.position,
                peers: peers,
                group: group)

            if  let article:SymbolGraph.Article = decl.article
            {
                (vertex.overview, vertex.details) = self.context.resolving(
                    namespace: namespace.module,
                    module: namespace.context,
                    scope: decl.scope)
                {
                    $0.link(article: article)
                }

                vertex.readme = article.file.map { self.current.id + $0 }
            }

            self.decls.append(vertex)
        }

        return miscellaneous
    }
}
