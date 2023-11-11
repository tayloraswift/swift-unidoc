import CodelinkResolution
import JSON
import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDiagnostics
import UnidocRecords

public
struct DynamicLinker:~Copyable
{
    private
    let context:DynamicContext
    private
    let modules:[ModuleContext]

    /// Protocol conformances for each declaration in the **current** snapshot.
    private
    let conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Int>>

    public private(set)
    var diagnostics:DiagnosticContext<DynamicSymbolicator>
    private
    var extensions:Extensions

    /// Maps vertices to groups.
    private
    var memberships:[Int32: Unidoc.Scalar]
    private
    var next:
    (
        autogroup:Unidoc.Counter<UnidocPlane.Autogroup>,
        topic:Unidoc.Counter<UnidocPlane.Topic>
    )

    private
    var articles:[Volume.Vertex.Article]
    private
    var decls:[Volume.Vertex.Decl]

    private
    var groups:[Volume.Group]

    private
    init(context:DynamicContext,
        modules:[ModuleContext],
        conformances:SymbolGraph.Plane<UnidocPlane.Decl, ProtocolConformances<Int>>,
        diagnostics:DiagnosticContext<DynamicSymbolicator>,
        extensions:Extensions)
    {
        self.context = context
        self.modules = modules

        self.conformances = conformances
        self.diagnostics = diagnostics
        self.extensions = extensions

        self.memberships = [:]

        self.next.autogroup = .init(zone: context.current.edition)
        self.next.topic = .init(zone: context.current.edition)

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
        let modules:[ModuleContext] = context.modules()

        var diagnostics:DiagnosticContext<DynamicSymbolicator> = .init()
        var extensions:Extensions = .init(zone: context.current.edition)

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
            context: context,
            modules: modules,
            conformances: conformances,
            diagnostics: diagnostics,
            extensions: extensions)
    }

    public consuming
    func link() -> Mesh
    {
        self.autogroup()

        var cultures:[Volume.Vertex.Culture] = self.link()
        var meta:Volume.Meta.LinkDetails = .init(abi: self.current.metadata.abi,
            requirements: self.current.metadata.requirements)

        var vertices:[Volume.Vertex] = [.global(.init(id: context.current.edition.global))]

        vertices.reserveCapacity(context.current.files.count
            + self.articles.count
            + self.decls.count
            + cultures.count
            + 1)

        var mapper:TreeMapper = .init(zone: context.current.edition)
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

        let context:DynamicContext = self.context

        let extensions:Extensions = self.extensions
        var groups:[Volume.Group] = self.groups

        _ = consume self

        //  Compute shoots for out-of-package extended types.
        for d:Int32 in context.current.decls.nodes.indices
        {
            if  case nil = context.current.decls.nodes[d].decl,
                let foreign:Unidoc.Scalar = context.current.scalars.decls[d]
            {
                vertices.append(.foreign(mapper.register(foreign: foreign, with: context)))
            }
        }

        //  Compute unweighted stats
        for (c, culture):(Int, SymbolGraph.Culture) in zip(cultures.indices,
            context.current.cultures)
        {
            guard let range:ClosedRange<Int32> = culture.decls
            else
            {
                continue
            }
            for d:Int32 in range
            {
                if  let decl:SymbolGraph.Decl = context.current.decls.nodes[d].decl
                {
                    let coverage:WritableKeyPath<Volume.Stats.Coverage, Int> = .classify(decl,
                        from: context.current,
                        at: d)

                    let decl:WritableKeyPath<Volume.Stats.Decl, Int> = .classify(decl)

                    cultures[c].census.unweighted.coverage[keyPath: coverage] += 1
                    cultures[c].census.unweighted.decls[keyPath: decl] += 1

                    meta.census.unweighted.coverage[keyPath: coverage] += 1
                    meta.census.unweighted.decls[keyPath: decl] += 1
                }
            }
        }

        //  Create extension records, and compute weighted stats.
        meta.census.weighted = meta.census.unweighted
        for c:Int in cultures.indices
        {
            cultures[c].census.weighted = cultures[c].census.unweighted
        }

        for (signature, `extension`):(ExtensionSignature, Extension) in extensions.sorted()
            where !`extension`.isEmpty
        {
            for f:Unidoc.Scalar in `extension`.features
            {
                if  let decl:SymbolGraph.Decl = context[f.package]?.decls[f.citizen]?.decl
                {
                    let bin:WritableKeyPath<Volume.Stats.Decl, Int> = .classify(decl)

                    cultures[signature.culture].census.weighted.decls[keyPath: bin] += 1
                    meta.census.weighted.decls[keyPath: bin] += 1
                }
            }

            let assembled:Volume.Group.Extension = context.assemble(
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
            context.current.files.indices,
            context.current.files)
        {
            vertices.append(.file(.init(id: context.current.edition + f, symbol: file)))
        }
        //  Move culture vertices to the combined buffer.
        for culture:Volume.Vertex.Culture in cultures
        {
            vertices.append(.culture(culture))
        }

        let (trees, index):([Volume.TypeTree], JSON) = mapper.build(cultures: cultures)

        return .init(vertices: vertices,
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
            },
            meta: meta)
    }
}
extension DynamicLinker
{
    var current:SnapshotObject { self.context.current }
}
extension DynamicLinker
{
    private mutating
    func autogroup()
    {
        //  Create a synthetic topic containing all the cultures. This will become a “See Also”
        //  for their module pages, unless they belong to a custom topic group.
        let cultures:Volume.Group.Automatic = .init(id: self.next.autogroup.id(),
            scope: self.current.edition.global,
            members: self.current.cultures.indices.sorted
            {
                self.current.namespaces[$0] <
                self.current.namespaces[$1]
            }
            .map
            {
                self.current.edition + $0
            })

        self.groups.append(.automatic(cultures))

        for c:Int in self.current.cultures.indices
        {
            self.memberships[c * .module] = cultures.id
        }
    }
    private mutating
    func link() -> [Volume.Vertex.Culture]
    {
        //  First pass to create the topic records, which also populates topic memberships.
        for ((c, culture), context):((Int, SymbolGraph.Culture), ModuleContext)
            in zip(zip(
                self.current.cultures.indices,
                self.current.cultures),
            self.modules)
        {
            //  Create topic records.
            self.link(topics: culture.topics,
                with: context,
                from: (c, self.current.namespaces[c]))
        }

        //  Second pass to create various vertex records, which reads from the ``topics``.
        for ((c, namespace, culture), context):
            ((Int, ModuleIdentifier, SymbolGraph.Culture), ModuleContext) in zip(
            self.current.modules,
            self.modules)
        {
            //  Create decl records.
            for decls:SymbolGraph.Namespace in culture.namespaces
            {
                let namespace:ModuleIdentifier = self.current.namespaces[decls.index]

                guard
                let n:Unidoc.Scalar = self.current.scalars.namespaces[decls.index]
                else
                {
                    self.diagnostics[nil] = DroppedExtensionsError.extending(namespace,
                        count: decls.range.count)
                    continue
                }

                let miscellaneous:[Unidoc.Scalar] = self.link(decls: decls.range,
                    under: (n, namespace),
                    with: context,
                    from: c)

                if  miscellaneous.isEmpty
                {
                    continue
                }

                //  Create top-level autogroup.
                self.groups.append(.automatic(.init(id: self.next.autogroup.id(),
                    scope: self.current.edition + c,
                    members: self.context.sort(lexically: consume miscellaneous))))
            }
            //  Create article records.
            if  let articles:ClosedRange<Int32> = culture.articles
            {
                self.link(articles: articles,
                    with: context,
                    from: (c, namespace))
            }
        }

        return self.current.modules.map
        {
            self.link(culture: $0.culture, named: $0.name, at: $0.index)
        }
    }
}
extension DynamicLinker
{
    private mutating
    func link(topics:[SymbolGraph.Topic],
        with context:ModuleContext,
        from culture:(index:Int, id:ModuleIdentifier))
    {
        let n:Unidoc.Scalar = self.current.edition + culture.index

        for topic:SymbolGraph.Topic in topics
        {
            var record:Volume.Group.Topic = .init(id: self.next.topic.id(),
                culture: n,
                scope: n)

            (record.overview, record.members) = self.diagnostics.resolving(
                namespace: culture.id,
                global: self.context,
                module: context)
            {
                $0.link(topic: topic)
            }

            self.groups.append(.topic(record))

            for case .scalar(let master) in record.members
            {
                //  This may replace a synthesized topic.
                if  let local:Int32 = master - self.current.edition
                {
                    self.memberships[local] = record.id
                }
            }
        }
    }
}
extension DynamicLinker
{
    private mutating
    func link(culture:SymbolGraph.Culture,
        named name:ModuleIdentifier,
        at index:Int) -> Volume.Vertex.Culture
    {
        let scalar:Unidoc.Scalar = self.current.edition + index
        var vertex:Volume.Vertex.Culture = .init(id: scalar,
            module: culture.module,
            group: self.memberships.removeValue(forKey: scalar.citizen))

        if  let article:SymbolGraph.Article = culture.article
        {
            vertex.readme = article.file.map { self.current.edition + $0 }

            (vertex.overview, vertex.details) = self.diagnostics.resolving(namespace: name,
                global: self.context,
                module: self.modules[index])
            {
                $0.link(article: article)
            }
        }

        return vertex
    }

    private mutating
    func link(articles range:ClosedRange<Int32>,
        with context:ModuleContext,
        from culture:(index:Int, id:ModuleIdentifier))
    {
        for (a, node):(Int32, SymbolGraph.ArticleNode) in zip(
            self.current.articles.nodes[range].indices,
            self.current.articles.nodes[range])
        {
            let symbol:Symbol.Article = self.current.articles.symbols[a]
            var vertex:Volume.Vertex.Article = .init(id: self.current.edition + a,
                stem: .init(culture.id, symbol.name),
                culture: self.current.edition + culture.index,
                file: node.body.file.map { self.current.edition + $0 },
                headline: node.headline,
                group: self.memberships.removeValue(forKey: a))

            (vertex.overview, vertex.details) = self.diagnostics.resolving(
                namespace: culture.id,
                global: self.context,
                module: context)
            {
                $0.link(article: node.body)
            }

            self.articles.append(vertex)
        }
    }

    /// Returns a list of uncategorized top-level declarations.
    private mutating
    func link(decls range:ClosedRange<Int32>,
        under namespace:(scalar:Unidoc.Scalar, id:ModuleIdentifier),
        with context:ModuleContext,
        from culture:Int) -> [Unidoc.Scalar]
    {
        var miscellaneous:[Unidoc.Scalar] = []

        for (d, ((symbol, node), conformances)):
            (Int32, ((Symbol.Decl, SymbolGraph.DeclNode), ProtocolConformances<Int>))
            in zip(range, zip(zip(
                    self.current.decls.symbols[range],
                    self.current.decls.nodes[range]),
                self.conformances[range]))
        {
            /// Is this declaration a member of a topic?
            let group:Unidoc.Scalar? = self.memberships.removeValue(forKey: d)
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
                decl.path.count == 1
            {
                miscellaneous.append(d)
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
                    let signature:ExtensionSignature = .init(
                        conditions: conformance.conditions,
                        culture: conformance.culture,
                        extends: d)
                    self.extensions[signature].features.append(f)
                }
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
                    culture: culture,
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
                stem: .init(namespace.id, decl.path, orientation: decl.phylum.orientation),
                requirements: self.context.sort(lexically: requirements),
                superforms: self.context.sort(lexically: superforms),
                namespace: namespace.scalar,
                culture: self.current.edition + culture,
                scope: scope.map { self.context.expand($0) } ?? [],
                file: decl.location.map { self.current.edition + $0.file },
                position: decl.location?.position,
                group: group)

            if  let article:SymbolGraph.Article = decl.article
            {
                (vertex.overview, vertex.details) = self.diagnostics.resolving(
                    namespace: namespace.id,
                    global: self.context,
                    module: context,
                    scope: decl.phylum.scope(trimming: decl.path))
                {
                    $0.link(article: article)
                }
            }

            self.decls.append(vertex)
        }

        return miscellaneous
    }
}
