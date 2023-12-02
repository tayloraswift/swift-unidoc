import CodelinkResolution
import JSON
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDiagnostics
import UnidocRecords

public
struct DynamicLinker:~Copyable
{
    private
    let contexts:[SymbolGraph.ModuleContext]
    private
    let global:DynamicContext

    /// Protocol conformances for each declaration in the **current** snapshot.
    private
    let conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Int>>

    public private(set)
    var diagnostics:DiagnosticContext<DynamicSymbolicator>
    private
    var extensions:Extensions

    /// A table mapping nested declarations to their enclosing extensions.
    ///
    /// This is immutable even though ``extensions`` is mutable, because we never introduce
    /// new nested declarations after building the initial ``extensions`` structure.
    private
    let extensionContainingNested:[Int32: Unidoc.Scalar]
    /// A table maping vertices to topics or autogroups.
    private
    var groupContainingMember:[Int32: Unidoc.Scalar]

    private
    var next:
    (
        autogroup:Unidoc.Counter<UnidocPlane.Autogroup>,
        topic:Unidoc.Counter<UnidocPlane.Topic>
    )

    private
    var cultures:[Volume.Vertex.Culture]
    private
    var articles:[Volume.Vertex.Article]
    private
    var decls:[Volume.Vertex.Decl]

    private
    var groups:[Volume.Group]

    private
    init(
        contexts:[SymbolGraph.ModuleContext],
        global:DynamicContext,
        conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Int>>,
        diagnostics:DiagnosticContext<DynamicSymbolicator>,
        extensions:Extensions)
    {
        self.contexts = contexts
        self.global = global

        self.conformances = conformances
        self.diagnostics = diagnostics
        self.extensions = extensions

        self.extensionContainingNested = extensions.byNested()
        self.groupContainingMember = [:]

        self.next.autogroup = .init(zone: global.current.id)
        self.next.topic = .init(zone: global.current.id)

        self.cultures = []
        self.articles = []
        self.decls = []

        self.groups = []
    }
}
extension DynamicLinker
{
    public
    init(context:DynamicContext)
    {
        let modules:[SymbolGraph.ModuleContext] = context.modules()

        var diagnostics:DiagnosticContext<DynamicSymbolicator> = .init()
        var extensions:Extensions = .init(zone: context.current.id)

        let conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Int>> =
            context.current.decls.nodes.map
        {
            $1.extensions.isEmpty ? [:] : extensions.add($1.extensions,
                extending: $0,
                context: context,
                modules: modules,
                diagnostics: &diagnostics)
        }

        self.init(
            contexts: modules,
            global: context,
            conformances: conformances,
            diagnostics: diagnostics,
            extensions: extensions)

        self.autogroup()
        self.cultures = self.link()
    }

    public consuming
    func finalize() -> Mesh
    {
        var vertices:[Volume.Vertex] = []

        vertices.reserveCapacity(self.current.files.count
            + self.cultures.count
            + self.articles.count
            + self.decls.count
            + 1)

        var mapper:TreeMapper = .init(zone: self.current.id)
        for vertex:Volume.Vertex.Article in self.articles
        {
            vertices.append(.article(vertex))
            mapper.add(vertex)
        }
        for vertex:Volume.Vertex.Decl in self.decls
        {
            vertices.append(.decl(vertex))
            mapper.add(vertex)
        }

        let extensions:Extensions = self.extensions
        let global:DynamicContext = self.global

        var snapshot:Volume.SnapshotDetails = .init(abi: self.current.metadata.abi,
            requirements: self.current.metadata.requirements)

        var groups:[Volume.Group] = self.groups
        var cultures:[Volume.Vertex.Culture] = (consume self).cultures

        //  Compute shoots for out-of-package extended types.
        for d:Int32 in global.current.decls.nodes.indices
        {
            if  case nil = global.current.decls.nodes[d].decl,
                let foreign:Unidoc.Scalar = global.current.scalars.decls[d]
            {
                vertices.append(.foreign(mapper.register(foreign: foreign, with: global)))
            }
        }

        //  Compute unweighted stats
        for (c, culture):(Int, SymbolGraph.Culture) in zip(cultures.indices,
            global.current.cultures)
        {
            guard let range:ClosedRange<Int32> = culture.decls
            else
            {
                continue
            }
            for d:Int32 in range
            {
                if  let decl:SymbolGraph.Decl = global.current.decls.nodes[d].decl
                {
                    let coverage:WritableKeyPath<Volume.Stats.Coverage, Int> = .classify(decl,
                        from: global.current,
                        at: d)

                    let decl:WritableKeyPath<Volume.Stats.Decl, Int> = .classify(decl)

                    cultures[c].census.unweighted.coverage[keyPath: coverage] += 1
                    cultures[c].census.unweighted.decls[keyPath: decl] += 1

                    snapshot.census.unweighted.coverage[keyPath: coverage] += 1
                    snapshot.census.unweighted.decls[keyPath: decl] += 1
                }
            }
        }

        //  Create extension records, and compute weighted stats.
        snapshot.census.weighted = snapshot.census.unweighted
        for c:Int in cultures.indices
        {
            cultures[c].census.weighted = cultures[c].census.unweighted
        }

        for (signature, `extension`):(ExtensionSignature, Extension) in extensions.sorted()
            where !`extension`.isEmpty
        {
            for f:Unidoc.Scalar in `extension`.features
            {
                if  let decl:SymbolGraph.Decl = global[f.package]?.decls[f.citizen]?.decl
                {
                    let bin:WritableKeyPath<Volume.Stats.Decl, Int> = .classify(decl)

                    cultures[signature.culture].census.weighted.decls[keyPath: bin] += 1
                    snapshot.census.weighted.decls[keyPath: bin] += 1
                }
            }

            let assembled:Volume.Group.Extension = global.assemble(
                extension: `extension`,
                signature: signature)

            defer
            {
                groups.append(.extension(assembled))
            }

            //  Extensions that only contain subforms are not interesting.
            if  assembled.nested.isEmpty,
                assembled.features.isEmpty,
                assembled.conformances.isEmpty
            {
                continue
            }

            mapper.update(with: assembled)
        }

        //  Create file vertices.
        for (f, file):(Int32, Symbol.File) in zip(
            global.current.files.indices,
            global.current.files)
        {
            vertices.append(.file(.init(id: global.current.id + f, symbol: file)))
        }
        //  Move culture vertices to the combined buffer.
        for culture:Volume.Vertex.Culture in cultures
        {
            vertices.append(.culture(culture))
        }

        let (trees, index):([Volume.TypeTree], JSON) = mapper.build(cultures: cultures)

        vertices.append(.global(.init(id: global.current.id.global, snapshot: snapshot)))

        return .init(
            vertices: vertices,
            groups: groups,
            index: index,
            trees: trees,
            tree: cultures.map
            {
                .init(shoot: $0.shoot, style: .stem(.package))
            }
                .sorted
            {
                $0.shoot < $1.shoot
            })
    }
}
extension DynamicLinker
{
    var current:DynamicContext.Snapshot { self.global.current }

    private
    var modules:SymbolGraph.ModuleView
    {
        .init(namespaces: self.current.namespaces,
            cultures: self.current.cultures,
            contexts: self.contexts,
            edition: self.current.id)
    }
}
extension DynamicLinker
{
    private mutating
    func autogroup()
    {
        //  Create a synthetic topic containing all the cultures. This will become a “See Also”
        //  for their module pages, unless they belong to a custom topic group.
        let cultures:Volume.Group.Automatic = .init(id: self.next.autogroup.id(),
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

        self.groups.append(.automatic(cultures))

        for c:Int in self.current.cultures.indices
        {
            self.groupContainingMember[c * .module] = cultures.id
        }
    }

    private mutating
    func link() -> [Volume.Vertex.Culture]
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
                        let p:Unidoc.Scalar = self.global[f.package]?.scope(of: f)
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
                            let signature:ExtensionSignature = .init(
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
                let scalar:Unidoc.Scalar = self.current.scalars.namespaces[decls.index]
                else
                {
                    self.diagnostics[nil] = DroppedExtensionsError.extending(module,
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
                self.groups.append(.automatic(.init(id: self.next.autogroup.id(),
                    scope: namespace.culture,
                    members: self.global.sort(lexically: consume miscellaneous))))
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
extension DynamicLinker
{
    private mutating
    func link(topics:[SymbolGraph.Topic],
        under namespace:SymbolGraph.NamespaceContext<Void>,
        scope:[String] = [],
        owner:Unidoc.Scalar)
    {
        for topic:SymbolGraph.Topic in topics
        {
            var record:Volume.Group.Topic = .init(id: self.next.topic.id(),
                culture: namespace.culture,
                scope: owner)

            (record.overview, record.members) = self.diagnostics.resolving(
                namespace: namespace.module,
                module: namespace.context,
                global: self.global,
                scope: scope)
            {
                $0.link(topic: topic)
            }

            self.groups.append(.topic(record))

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
extension DynamicLinker
{
    private mutating
    func link(culture:SymbolGraph.Culture,
        under namespace:SymbolGraph.NamespaceContext<Void>) -> Volume.Vertex.Culture
    {
        var vertex:Volume.Vertex.Culture = .init(id: namespace.culture,
            module: culture.module,
            group: self.groupContainingMember[namespace.culture.citizen])

        if  let article:SymbolGraph.Article = culture.article
        {
            vertex.readme = article.file.map { self.current.id + $0 }

            (vertex.overview, vertex.details) = self.diagnostics.resolving(
                namespace: namespace.module,
                module: namespace.context,
                global: self.global)
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

            var vertex:Volume.Vertex.Article = .init(id: scalar,
                stem: .init(namespace.module, symbol.name),
                culture: namespace.culture,
                file: node.article.file.map { self.current.id + $0 },
                headline: node.headline,
                group: self.groupContainingMember[a])

            (vertex.overview, vertex.details) = self.diagnostics.resolving(
                namespace: namespace.module,
                module: namespace.context,
                global: self.global)
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
            let `extension`:Unidoc.Scalar? = self.extensionContainingNested[d]
            /// Is this declaration a member of a topic?
            let group:Unidoc.Scalar? = self.groupContainingMember[d]
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
                let implicit:ExtensionSignature = .init(conditions: [],
                    culture: namespace.c,
                    extends: s)

                self.extensions[implicit].subforms.append(d)
            }

            var vertex:Volume.Vertex.Decl = .init(id: d,
                flags: .init(
                    phylum: decl.phylum,
                    kinks: decl.kinks,
                    route: decl.route),
                signature: decl.signature.map { self.current.scalars.decls[$0] },
                symbol: symbol,
                stem: .init(namespace.module, decl.path, orientation: decl.phylum.orientation),
                requirements: self.global.sort(lexically: requirements),
                superforms: self.global.sort(lexically: superforms),
                namespace: namespace.id,
                culture: namespace.culture,
                scope: scope.map { self.global.expand($0) } ?? [],
                renamed: decl.renamed.map { self.current.scalars.decls[$0] } ?? nil,
                file: decl.location.map { self.current.id + $0.file },
                position: decl.location?.position,
                extension: `extension`,
                group: group)

            if  let article:SymbolGraph.Article = decl.article
            {
                (vertex.overview, vertex.details) = self.diagnostics.resolving(
                    namespace: namespace.module,
                    module: namespace.context,
                    global: self.global,
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
