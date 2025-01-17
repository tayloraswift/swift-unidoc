import FNV1
import LexicalPaths
import LinkResolution
import MarkdownABI
import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Signatures
import Snippets
import SourceDiagnostics
import Sources
import SymbolGraphCompiler
import SymbolGraphs
import Symbols
import UCF
import Unidoc

extension SSGC
{
    public
    struct Linker:~Copyable
    {
        private
        let doccommentParser:Markdown.Parser<Markdown.SwiftComment>
        private
        let markdownParser:Markdown.Parser<Markdown.SwiftFlavor>
        private
        let swiftParser:Markdown.SwiftLanguage?

        private
        var contexts:[Context]
        private
        var snippets:[String: Markdown.Snippet]
        private
        var router:Router<FNV24?, Int32>
        private
        var tables:Tables

        private
        var supplements:[Int32: (source:Markdown.Source, body:Markdown.SemanticDocument)]
        private
        var collations:ArticleCollations

        private
        init(
            doccommentParser:Markdown.Parser<Markdown.SwiftComment>,
            markdownParser:Markdown.Parser<Markdown.SwiftFlavor>,
            swiftParser:Markdown.SwiftLanguage?,
            contexts:[Context],
            tables:Tables)
        {
            self.doccommentParser = doccommentParser
            self.markdownParser = markdownParser
            self.swiftParser = swiftParser

            self.contexts = contexts
            self.snippets = [:]
            self.router = .init()
            self.tables = tables

            self.supplements = [:]
            self.collations = .init()
        }
    }
}
extension SSGC.Linker
{
    init(definitions:[String: Void],
        plugins:[any Markdown.CodeLanguageType],
        modules:[SymbolGraph.Module])
    {
        //  If we were given a plugin that says it can highlight swift,
        //  make it the default plugin for the doccomment parser.
        let swift:(any Markdown.CodeLanguageType)? = plugins.first { $0.name == "swift" }
        let tables:Tables = .init(definitions: definitions, modules: modules)

        self = .init(
            doccommentParser: .init(plugins: plugins, default: swift),
            markdownParser: .init(plugins: plugins),
            swiftParser: swift as? Markdown.SwiftLanguage,
            contexts: tables.graph.cultures.map { .init(id: $0.id) },
            tables: tables)
    }

    mutating
    func attach(snippets:[any SSGC.ResourceFile],
        indexes:[SSGC.ModuleIndex],
        projectRoot:Symbol.FileBase?) throws
    {
        /// Initialize the package-level resolution table with every module in at least one
        /// module index. If we do not do this, we will not be able to resolve noncausal links
        /// to symbols from extensions on types from other packages.
        let modules:Set<Symbol.Module> = indexes.reduce(into: [])
        {
            for module:Symbol.Module in $1.resolvableModules
            {
                $0.insert(module)
            }
        }
        for module:Symbol.Module in modules
        {
            self.tables.packageLinks.register(module)
        }

        for (offset, module):(Int, SSGC.ModuleIndex) in zip(self.contexts.indices, indexes)
        {
            guard
            case offset? = self.tables.modules[module.id]
            else
            {
                fatalError("Module '\(module.id)' appears in the wrong array position!")
            }

            {
                $0.causalLinks = module.resolvableLinks
                $0.causalURLs = module.resolvableLinks.caseFolded()
                $0.resources = module.resources.reduce(into: [:])
                {
                    $0[$1.name] = .init(file: $1, id: self.tables.intern($1.path))
                }
            } (&self.contexts[offset])

            self.allocate(declarations: module.declarations,
                as: module.language ?? .swift,
                at: offset)
        }

        //  This needs to be done in two passes, because unfurling extensions can intern
        //  additional symbols, which would otherwise create holes in the address space.
        self.allocateNodesFromExtensions(in: indexes)
        self.unfurlFeaturesFromExtensions(in: indexes)
        self.colorizeReexportedDeclarations(in: indexes)

        //  We attach snippets first, because they can be referenced by the markdown
        //  supplements. This works even if the snippet captions contain references to articles,
        //  because we only eagarly inline snippet captions as markdown AST nodes; codelink
        //  resolution does not take place until we link the written documentation.
        try self.attach(snippets: snippets, projectRoot: projectRoot)

        for (offset, module):(Int, SSGC.ModuleIndex) in zip(self.contexts.indices, indexes)
        {
            try self.attach(markdown: module.markdown, at: offset)
        }
    }

    private mutating
    func allocateNodesFromExtensions(in indexes:[SSGC.ModuleIndex])
    {
        for module:SSGC.ModuleIndex in indexes
        {
            for node:SSGC.Extension in module.extensions
            {
                self.tables.allocate(decl: node.extendee.id)
            }
        }
    }

    private mutating
    func unfurlFeaturesFromExtensions(in indexes:[SSGC.ModuleIndex])
    {
        for (offset, module):(Int, SSGC.ModuleIndex) in zip(self.contexts.indices, indexes)
        {
            self.unfurl(extensions: module.extensions,
                featuresBySymbol: module.features,
                at: offset)
        }
    }

    private mutating
    func colorizeReexportedDeclarations(in indexes:[SSGC.ModuleIndex])
    {
        var redirect:SSGC.Router<FNV24, (Int32, Int)> = .init()
        for (offset, module):(Int, SSGC.ModuleIndex) in zip(self.contexts.indices, indexes)
        {
            //  @_exported can duplicate a truly staggering number of declarations. To prevent
            //  this from creating a lot of almost-empty declaration nodes, we only track
            //  modules that re-export symbols from the same package.
            for (id, feature):(Symbol.Decl, SSGC.DeclAlias) in module.reexports
            {
                if  let i:Int32 = self.tables.citizen(id)
                {
                    let hash:FNV24 = .decl(id)
                    redirect[module.id, feature.path, feature.phylum][hash, default: []]
                        .append((i, offset))
                }
            }
        }

        self.tables.graph.colorize(reexports: redirect.paths, with: &self.tables.diagnostics)
    }
}
extension SSGC.Linker
{
    /// Allocates and binds addresses for the given declarations. Binding consists of populating
    /// the full name and phylum of a declaration. This function also exposes each of the
    /// declarations for codelink resolution.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method first, before calling any others.
    private mutating
    func allocate(declarations:[(id:Symbol.Module, decls:[SSGC.Decl])],
        as language:Phylum.Language,
        at offset:Int)
    {
        let destinations:
        [(
            allocated:SymbolGraph.Namespace,
            qualifier:Symbol.Module,
            decls:[SSGC.Decl]
        )] = declarations.reduce(into: [])
        {
            guard
            let (range, decls):(ClosedRange<Int32>, [SSGC.Decl]) = self.allocate(
                deduplicating: $1.decls,
                language: language)
            else
            {
                return
            }

            let allocated:SymbolGraph.Namespace = .init(
                range: range,
                index: self.tables.intern($1.id))

            $0.append((allocated, $1.id, decls))
        }
        ;
        {
            $0.reserveCapacity(destinations.reduce(0) { $0 + $1.allocated.range.count })

            for (allocated, qualifier, decls):
                (SymbolGraph.Namespace, Symbol.Module, [SSGC.Decl]) in destinations
            {
                for (i, decl):(Int32, SSGC.Decl) in zip(allocated.range, decls)
                {
                    let traits:UCF.DisambiguationTraits = decl.traits
                    //  Make the decl visible to codelink resolution.
                    self.tables.packageLinks[qualifier, decl.path].append(.init(
                        traits: traits,
                        decl: i,
                        heir: nil,
                        documented: decl.comment != nil,
                        inherited: false,
                        id: decl.id))
                    //  Assign the decl a URI, and record the decl’s hash
                    //  so we will know if it has a hash collision.
                    self.router[qualifier, decl.path, decl.phylum][traits.hash, default: []]
                        .append(i)

                    $0.append((decl, i, qualifier))
                }
            }
        } (&self.contexts[offset].decls)

        self.tables.graph.cultures[offset].namespaces = destinations.map(\.allocated)
    }

    private mutating
    func allocate(
        deduplicating decls:consuming [SSGC.Decl],
        language:Phylum.Language) -> (ClosedRange<Int32>, [SSGC.Decl])?
    {
        var scalars:(first:Int32, last:Int32)? = nil
        let kept:[SSGC.Decl] = decls.filter
        {
            guard
            let scalar:Int32 = self.tables.allocate(decl: $0, language: language)
            else
            {
                self.tables.diagnostics[nil] = .warning("""
                    Declaration '\($0.path)' was synthesized by multiple modules in this \
                    package and only one copy will be kept
                    """)
                return false
            }

            switch scalars
            {
            case  nil:              scalars = (scalar, scalar)
            case (let first, _)?:   scalars = (first,  scalar)
            }

            return true
        }

        if  case (let first, let last)? = scalars
        {
            return (first ... last, kept)
        }
        else
        {
            return nil
        }
    }

    /// This function also exposes any features manifested by the extensions for
    /// codelink resolution.
    ///
    /// -   Returns:
    ///     A (scalar, index) tuple for each compiled extension. If the
    ///     extension extends a symbol that has not yet been registered,
    ///     the scalar is newly allocated.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method second, after calling ``allocate(decls:)``.
    private mutating
    func unfurl(extensions:[SSGC.Extension],
        featuresBySymbol:[Symbol.Decl: SSGC.DeclAlias],
        at offset:Int)
    {
        self.contexts[offset].extensions = extensions.map
        {
            let extendee:Int32 = self.tables.intern($0.extendee.id)
            if  extendee >= self.tables.graph.decls.nodes.endIndex
            {
                fatalError("Extendee '\($0.extendee.id)' was never allocated!")
            }

            let namespace:Symbol.Module = $0.extendee.namespace
            let namespacePosition:Int = self.tables.intern(namespace)

            let conformances:[Int32] = $0.conformances.map { self.tables.intern($0) }
            let features:[Int32] = $0.features.map { self.tables.intern($0) }
            let nested:[Int32] = $0.nested.map { self.tables.intern($0) }

            //  Expose features for codelink resolution.
            for (f, id):(Int32, Symbol.Decl) in zip(features, $0.features)
            {
                guard
                let feature:SSGC.DeclAlias = featuresBySymbol[id]
                else
                {
                    continue
                }

                let featureAlias:UCF.PackageOverload = .init(traits: .init(
                        autograph: feature.autograph,
                        phylum: feature.phylum,
                        kinks: feature.kinks,
                        hash: .decl(.init(id, self: $0.extendee.id))),
                    decl: f,
                    heir: extendee,
                    documented: feature.documented,
                    inherited: true,
                    id: id)

                self.tables.packageLinks[namespace, $0.extendee.path, feature.path.last]
                    .append(featureAlias)
            }

            let index:Int = self.tables.graph.decls.nodes[extendee].push(.init(
                conditions: $0.conditions.map { $0.map { self.tables.intern($0) } },
                namespace: namespacePosition,
                culture: offset,
                conformances: conformances,
                features: features,
                nested: nested))

            return ($0, extendee, index)
        }
    }
}
extension SSGC.Linker
{
    private mutating
    func attach(snippets:[any SSGC.ResourceFile], projectRoot:Symbol.FileBase?) throws
    {
        guard
        let swift:Markdown.SwiftLanguage = self.swiftParser
        else
        {
            return
        }

        //  Right now we only do one pass over the snippets, since no one should be referencing
        //  snippets from other snippets.
        self.snippets = try snippets.reduce(into: [:])
        {
            let indexID:String?

            if  let projectRoot:Symbol.FileBase
            {
                indexID = "\(projectRoot.path)/\($1.path)"
            }
            else
            {
                indexID = nil
            }

            let snippet:(caption:String, slices:[Markdown.SnippetSlice]) = swift.parse(
                snippet: try $1.read(as: [UInt8].self),
                from: indexID)

            $0[$1.name] = .init(id: self.tables.intern($1.path),
                captionParser: self.doccommentParser,
                caption: snippet.caption,
                slices: snippet.slices)
        }
    }

    private mutating
    func attach(markdown:[any SSGC.ResourceFile], at offset:Int) throws
    {
        let namespace:Symbol.Module = self.tables.graph.namespaces[offset]

        var range:(first:Int32, last:Int32)? = nil
        var articles:[SSGC.Article] = []

        for file:any SSGC.ResourceFile in markdown
        {
            if  let article:SSGC.Article = try self.attach(supplement: file, in: namespace)
            {
                articles.append(article)

                guard case .standalone(id: let id) = article.type
                else
                {
                    continue
                }

                switch range
                {
                case  nil:              range = (id,    id)
                case (let first, _)?:   range = (first, id)
                }
            }
        }

        /// If there are any options with `global` scope, we need to propogate them
        /// to every other article in the same culture!
        var global:Markdown.SemanticMetadata.Options = [:]
        for article:SSGC.Article in articles
        {
            global.propogate(from: article.body.metadata.options)
        }
        for i:Int in articles.indices
        {
            articles[i].body.metadata.options.propogate(from: global)
        }

        self.tables.graph.cultures[offset].articles = range.map { $0.first ... $0.last }
        self.contexts[offset].articles = articles
    }

    /// Parses and stores the given supplemental documentation if it has a binding
    /// that resolves to a known symbol. If the parsed article lacks a symbol binding
    /// altogether, it is considered a standalone article.
    private mutating
    func attach(supplement:any SSGC.ResourceFile,
        in namespace:Symbol.Module) throws -> SSGC.Article?
    {
        //  We always intern the article’s file path, for diagnostics, even if
        //  we end up discarding the article.
        let file:Int32 = self.tables.intern(supplement.path)
        let source:Markdown.Source = .init(file: file,
            text: try supplement.read(as: String.self))

        let name:String = supplement.name

        let prefix:UCF.ArticleTable.Prefix

        let title:Markdown.Bytecode
        let titleLocation:SourceReference<Markdown.Source>?

        let route:SSGC.Route
        let id:Symbol.Article

        let supplement:SSGC.Supplement
        do
        {
            supplement = try source.parse(
                markdownParser: self.markdownParser,
                snippetsTable: self.snippets,
                diagnostics: &self.tables.diagnostics)
        }
        catch let error as SSGC.SupplementError
        {
            self.tables.diagnostics[source.origin] = error
            return nil
        }
        catch // I wish swift had typed throws
        {
            fatalError("unreachable")
        }

        switch supplement.type
        {
        case .supplementWithHeading(let custom):
            //  Right now, the only way we can get one of these is via `@TechnologyRoot`.
            return .init(type: .culture(title: custom), file: file, body: supplement.body)

        case .supplement(let binding):
            let decl:Int32?
            do
            {
                decl = try self.tables.resolve(binding: binding, in: namespace)
            }
            catch let diagnosis as any Diagnostic<SSGC.Symbolicator>
            {
                self.tables.diagnostics[binding.source] = diagnosis
                return nil
            }
            catch let error
            {
                self.tables.diagnostics[binding.source] = .error(error)
                return nil
            }

            if  let decl:Int32
            {
                {
                    if  case nil = $0
                    {
                        $0 = (source, supplement.body)
                    }
                    else
                    {
                        self.tables.diagnostics[binding.source] = SSGC.SupplementError.multiple
                    }
                } (&self.supplements[decl])

                return nil
            }
            else
            {
                return .init(type: .culture(title: nil), file: file, body: supplement.body)
            }

        case .standalone(let heading, at: let sourceLocation):
            prefix = .documentation(namespace)
            title = heading
            titleLocation = sourceLocation
            route = .article(namespace, name)
            id = .article(namespace, name)

        case .tutorials(let headline):
            prefix = .tutorials(namespace)
            title = .init { $0 += headline }
            titleLocation = nil
            route = .article(namespace, "index.tutorial")
            id = .tutorial(namespace, "index")

        case .tutorial(let headline):
            //  To DocC, tutorials are an IMAX experience. To us, they are just articles.
            prefix = .tutorials(namespace)
            title = .init { $0 += headline }
            titleLocation = nil
            route = .article(namespace, "\(name).tutorial")
            id = .tutorial(namespace, name)
        }

        if  let id:Int32 = self.tables.allocate(article: id, title: title)
        {
             //  Make the standalone article visible for doclink resolution.
            self.tables.articleLinks[prefix, name] = id
            self.router[route][nil, default: []].append(id)
            return .init(type: .standalone(id: id), file: file, body: supplement.body)
        }
        else if
            let titleLocation:SourceReference<Markdown.Source>
        {
            self.tables.diagnostics[titleLocation] = SSGC.ArticleError.duplicated(name: name)
            return nil
        }
        else
        {
            self.tables.diagnostics[source.origin] = SSGC.ArticleError.duplicated(name: name)
            return nil
        }
    }
}

extension SSGC.Linker
{
    /// This throws an error if and only if a file system error occurs. This is fatal
    /// because there is already logic in the linker to handle the case where files are
    /// missing.
    mutating
    func collate() throws
    {
        for (offset, context):(Int, Context) in zip(self.contexts.indices, self.contexts)
        {
            for article:SSGC.Article in context.articles
            {
                let id:Int32 = article.id(in: offset)

                try self.tables.inline(resources: context.resources,
                    into: article.body.details,
                    with: self.swiftParser)

                self.tables.index(normalizing: article.body, id: id)
            }
        }

        for context:Context in self.contexts
        {
            for (d, i, _):(SSGC.Decl, Int32, Symbol.Module) in context.decls
            {
                try self.collate(decl: d, at: i, context: context)
            }
            for (e, i, j):(SSGC.Extension, Int32, Int) in context.extensions
            {
                try self.collate(extension: e, at: i, index: j)
            }
        }
    }

    private mutating
    func collate(decl:SSGC.Decl, at i:Int32, context:Context) throws
    {
        let signature:Signature<Int32> = decl.signature.map { self.tables.intern($0) }

        //  Sort for deterministic addresses.
        let requirements:[Int32] = decl.requirements.sorted().map { self.tables.intern($0) }
        let inhabitants:[Int32] = decl.inhabitants.sorted().map { self.tables.intern($0) }
        let superforms:[Int32] = decl.superforms.sorted().map { self.tables.intern($0) }
        /// We don’t have a great way to choose which origin to keep, so we just keep the first
        /// one in alphabetical order.
        let origin:Int32? = decl.origins.sorted().first.map { self.tables.intern($0) }

        let location:SourceLocation<Int32>? = decl.location?.map
        {
            self.tables.intern($0)
        }

        let comment:Markdown.Source? = decl.comment.map
        {
            .init(comment: $0, in: location?.file)
        }

        let article:SSGC.ArticleCollation?
        var scope:[String] { decl.phylum.scope(trimming: decl.path) }

        switch (comment, self.supplements.removeValue(forKey: i))
        {
        case (nil, nil):
            article = nil

        case (let comment?, nil):
            /// The file associated with the doccomment is always the same as
            /// the file the declaration itself lives in, so we would only ever
            /// care about the file associated with the supplement.
            article = .init(combined: comment.parse(
                    markdownParser: self.doccommentParser,
                    snippetsTable: self.snippets,
                    diagnostics: &self.tables.diagnostics),
                scope: scope,
                file: nil)

        case (let comment?, let supplement?):
            if  case .override? = supplement.body.metadata.merge
            {
                fallthrough
            }

            let body:Markdown.SemanticDocument = comment.parse(
                markdownParser: self.doccommentParser,
                snippetsTable: self.snippets,
                diagnostics: &self.tables.diagnostics)

            article = .init(combined: body.merged(appending: supplement.body),
                scope: scope,
                file: supplement.source.origin?.file)

        case (nil, let supplement?):
            article = .init(combined: supplement.body,
                scope: scope,
                file: supplement.source.origin?.file)
        }

        if  let article:SSGC.ArticleCollation
        {
            try self.tables.inline(resources: context.resources,
                into: article.combined.details,
                with: self.swiftParser)

            self.tables.index(normalizing: article.combined, id: i)

            self.collations[i] = article
        }

        {
            $0?.requirements = requirements
            $0?.inhabitants = inhabitants
            $0?.superforms = superforms
            $0?.origin = origin

            $0?.signature = signature
            $0?.location = location

        } (&self.tables.graph.decls.nodes[i].decl)

    }

    /// Links extensions that have already been assigned addresses.
    ///
    /// This throws an error if and only if a file system error occurs. This is fatal because
    /// there is already logic in the linker to handle the case where files are missing.
    private mutating
    func collate(extension:SSGC.Extension, at i:Int32, index j:Int) throws
    {
        //  Extensions can have many constituent extension blocks, each potentially
        //  with its own doccomment. It’s not clear to me how to combine them,
        //  so for now, we just keep the longest doccomment and discard all the others,
        //  like DocC does. (Except DocC does this across all extensions with the
        //  same extended type.)
        //  https://github.com/apple/swift-docc/pull/369
        var location:SourceLocation<Symbol.File>? = nil
        var comment:SSGC.DocumentationComment? = nil
        var longest:Int = 0

        for block:SSGC.Extension.Block in `extension`.blocks
        {
            if  let current:SSGC.DocumentationComment = block.comment
            {
                //  This is really, really stupid, but we need a way to break
                //  ties, and we can’t use source location for this, as it is
                //  not always available.
                let length:Int = current.text.count
                if (longest, comment?.text ?? "") < (length, current.text)
                {
                    location = block.location
                    comment = current
                    longest = length
                }
            }
        }

        guard
        let comment:SSGC.DocumentationComment
        else
        {
            return
        }

        //  Only intern the file path for the extension block with the longest comment
        let file:Int32? = location.map { self.tables.intern($0.file) }
        let markdown:Markdown.Source = .init(comment: comment, in: file)

        let collation:SSGC.ArticleCollation = .init(combined: markdown.parse(
                markdownParser: self.doccommentParser,
                snippetsTable: self.snippets,
                diagnostics: &self.tables.diagnostics),
            scope: [String].init(`extension`.extendee.path),
            file: file)

        let c:Int = self.tables.graph.decls.nodes[i].extensions[j].culture

        try self.tables.inline(resources: self.contexts[c].resources,
            into: collation.combined.details,
            with: self.swiftParser)

        //  FIXME: We should index the anchors in the extension documentation, but
        //  extensions have 2-dimensional coordinates, and we don’t currently have a way to
        //  event link to them in the first place.
        self.tables.index(normalizing: collation.combined, id: nil)

        self.collations[i, j] = collation
    }
}
extension SSGC.Linker
{
    mutating
    func link() -> SymbolGraph
    {
        for (offset, context):(Int, Context) in zip(self.contexts.indices, self.contexts)
        {
            for (_, i, namespace):(SSGC.Decl, Int32, Symbol.Module) in context.decls
            {
                /// Pass this even if nil, in case the declaration has a rename target.
                let article:SSGC.ArticleCollation? = self.collations.move(i)
                self.tables.link(article: article,
                    in: context,
                    as: i,
                    under: namespace)
            }

            for (_, i, j):(SSGC.Extension, Int32, Int) in context.extensions
            {
                guard
                let article:SSGC.ArticleCollation = self.collations.move(i, j)
                else
                {
                    continue
                }

                self.tables.link(article: article,
                    extension: (i, j),
                    contexts: self.contexts)
            }

            for article:SSGC.Article in context.articles
            {
                self.tables.link(article: article, in: context, at: offset)
            }
        }

        self.tables.graph.colorize(routes: self.router.paths, with: &self.tables.diagnostics)
        return self.tables.graph
    }

    var diagnostics:Diagnostics<SSGC.Symbolicator>
    {
        consuming get
        {
            self.tables.diagnostics
        }
    }
}
