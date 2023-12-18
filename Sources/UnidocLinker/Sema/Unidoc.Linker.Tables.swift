import CodelinkResolution
import JSON
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDiagnostics
import UnidocRecords

extension Unidoc.Linker
{
    struct Tables:~Copyable
    {
        private
        let contexts:[SymbolGraph.ModuleContext]
        private(set)
        var context:Unidoc.Linker

        /// Protocol conformances for each declaration in the **current** snapshot.
        private
        let conformances:SymbolGraph.Table<SymbolGraph.DeclPlane, ProtocolConformances<Int>>

        /// A table mapping nested declarations to their enclosing extensions.
        ///
        /// This is immutable even though ``extensions`` is mutable, because we never introduce
        /// new nested declarations after building the initial ``extensions`` structure.
        private
        let extensionContainingNested:[Int32: Unidoc.Group.ID]
        /// A table maping vertices to topics or autogroups.
        private
        var groupContainingMember:[Int32: Unidoc.Group.ID]

        private
        var next:
        (
            polygon:Unidoc.Counter<SymbolGraph.AutogroupPlane>,
            topic:Unidoc.Counter<SymbolGraph.TopicPlane>
        )

        private(set)
        var extensions:Extensions
        var articles:[Unidoc.Vertex.Article]
        var decls:[Unidoc.Vertex.Decl]

        var groups:Unidoc.Volume.Groups

        private
        init(
            contexts:consuming [SymbolGraph.ModuleContext],
            context:consuming Unidoc.Linker,
            conformances:SymbolGraph.Table<SymbolGraph.DeclPlane, ProtocolConformances<Int>>,
            extensions:Extensions)
        {
            self.contexts = contexts
            self.context = context

            self.conformances = conformances

            self.extensionContainingNested = extensions.byNested()
            self.groupContainingMember = [:]

            self.next.polygon = .init(zone: self.context.current.id)
            self.next.topic = .init(zone: self.context.current.id)

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

        var extensions:Unidoc.Linker.Extensions = .init(zone: context.current.id)

        let conformances:SymbolGraph.Table<SymbolGraph.DeclPlane, ProtocolConformances<Int>> =
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
    /// This **must** be called before ``linkCultures``!
    mutating
    func linkProducts() -> [Unidoc.Vertex.Product]
    {
        var productPolygon:Unidoc.Group.Polygon = .init(id: self.next.polygon.id(),
            scope: self.current.id.global)

        var products:[Unidoc.Vertex.Product] = []
            products.reserveCapacity(self.current.metadata.products.count)

        for (p, product):(Int32, SymbolGraph.Product) in zip(
            self.current.metadata.products.indices,
            self.current.metadata.products)
        {
            var requirements:[Unidoc.Scalar] = product.cultures
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
                    requirements.append(q)
                }
            }

            let product:Unidoc.Vertex.Product = .init(id: self.current.id + p,
                requirements: requirements,
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
        let culturePolygon:Unidoc.Group.Polygon = .init(id: self.next.polygon.id(),
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
            self.groupContainingMember[c * .module] = culturePolygon.id
        }

        return products
    }

    /// This **must** be called after ``linkProducts``!
    mutating
    func linkCultures() -> [Unidoc.Vertex.Culture]
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
                    (Int32, (SymbolGraph.DeclNode, ProtocolConformances<Int>)) in zip(
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
                        for conformance:ProtocolConformance<Int> in conformances[to: p]
                        {
                            let signature:Unidoc.Linker.ExtensionSignature = .init(
                                conditions: conformance.conditions,
                                culture: conformance.culture,
                                extends: owner)
                            self.extensions[signature].features.append(f)
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

                //  Create top-level autogroup.
                self.groups.polygons.append(.init(id: self.next.polygon.id(),
                    scope: namespace.culture,
                    members: self.context.sort(lexically: consume miscellaneous)))
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
            var record:Unidoc.Group.Topic = .init(id: self.next.topic.id(),
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
                    self.groupContainingMember[local] = record.id
                }
            }
        }
    }
}
extension Unidoc.Linker.Tables
{
    private mutating
    func link(culture:SymbolGraph.Culture,
        under namespace:SymbolGraph.NamespaceContext<Void>) -> Unidoc.Vertex.Culture
    {
        var vertex:Unidoc.Vertex.Culture = .init(id: namespace.culture,
            module: culture.module,
            group: self.groupContainingMember[namespace.culture.citizen])

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

            var vertex:Unidoc.Vertex.Article = .init(id: scalar,
                stem: .article(namespace.module, symbol.name),
                culture: namespace.culture,
                file: node.article.file.map { self.current.id + $0 },
                headline: node.headline,
                group: self.groupContainingMember[a])

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
            /// Is this declaration contained in an extension?
            let `extension`:Unidoc.Group.ID? = self.extensionContainingNested[d]
            /// Is this declaration a member of a topic?
            let group:Unidoc.Group.ID? = self.groupContainingMember[d]
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

            let requirements:[Unidoc.Scalar] = decl.requirements.compactMap
            {
                self.current.scalars.decls[$0]
            }
            let superforms:[Unidoc.Scalar] = decl.superforms.compactMap
            {
                self.current.scalars.decls[$0]
            }

            for s:Unidoc.Scalar in superforms
            {
                let implicit:Unidoc.Linker.ExtensionSignature = .init(conditions: [],
                    culture: namespace.c,
                    extends: s)

                self.extensions[implicit].subforms.append(d)
            }

            var vertex:Unidoc.Vertex.Decl = .init(id: d,
                flags: .init(
                    phylum: decl.phylum,
                    kinks: decl.kinks,
                    route: decl.route),
                signature: decl.signature.map { self.current.scalars.decls[$0] },
                symbol: symbol,
                stem: .decl(namespace.module, decl.path, orientation: decl.phylum.orientation),
                requirements: self.context.sort(lexically: requirements),
                superforms: self.context.sort(lexically: superforms),
                namespace: namespace.id,
                culture: namespace.culture,
                scope: scope.map { self.context.expand($0) } ?? [],
                renamed: decl.renamed.map { self.current.scalars.decls[$0] } ?? nil,
                file: decl.location.map { self.current.id + $0.file },
                position: decl.location?.position,
                extension: `extension`,
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
            }

            self.decls.append(vertex)
        }

        return miscellaneous
    }
}
