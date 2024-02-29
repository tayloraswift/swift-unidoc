import CodelinkResolution
import MarkdownABI
import MarkdownAST
import SymbolGraphCompiler
import SymbolGraphs
import Symbols

extension SSGC
{
    struct Symbolizer
    {
        /// Interned module names. This only contains modules that are not included in the
        /// symbol graph being linked.
        private
        var modules:[Symbol.Module: Int]

        private
        var articles:[Symbol.Article: Int32]
        private
        var decls:[Symbol.Decl: Int32]
        private
        var files:[Symbol.File: Int32]

        var graph:SymbolGraph

        init(modules:[SymbolGraph.Module])
        {
            self.modules = [:]

            self.articles = [:]
            self.decls = [:]
            self.files = [:]

            self.graph = .init(modules: modules)
        }
    }
}
extension SSGC.Symbolizer
{
    var importAll:[Symbol.Module]
    {
        .init(self.graph.namespaces[self.graph.cultures.indices])
    }
}
extension SSGC.Symbolizer
{
    /// Indexes the given article and appends it to the symbol graph, if an article with the
    /// same mangled name has not already been indexed. (This function checks for duplicates.)
    mutating
    func allocate(article:Symbol.Article, title:consuming Markdown.BlockHeading) -> Int32?
    {
        {
            if  case nil = $0
            {
                let headline:Markdown.Bytecode = .init
                {
                    //  Don’t emit the enclosing `h1` tag!
                    for element:Markdown.InlineElement in title.elements
                    {
                        element.emit(into: &$0)
                    }
                }
                let scalar:Int32 = self.graph.articles.append(.init(headline: headline),
                    id: article)
                $0 = scalar
                return scalar
            }
            else
            {
                return nil
            }
        } (&self.articles[article])
    }

    /// Indexes the given declaration and appends it to the symbol graph.
    ///
    /// This function only populates basic information (flags and path) about the declaration,
    /// the rest should only be added after completing a full pass over all the declarations and
    /// extensions.
    ///
    /// This function doesn’t check for duplicates.
    mutating
    func allocate(decl:SSGC.Decl) -> Int32
    {
        let vertex:SymbolGraph.Decl = .init(language: decl.language,
            phylum: decl.phylum,
            kinks: decl.kinks,
            path: decl.path)

        let scalar:Int32 = self.graph.decls.append(.init(decl: vertex),
            id: decl.id)

        self.decls[decl.id] = scalar
        return scalar
    }

    /// Indexes the declaration extended by the given extension and appends the (empty)
    /// declaration to the symbol graph, if it has not already been indexed. (This function
    /// checks for duplicates.)
    mutating
    func allocate(extension:SSGC.Extension) -> Int32
    {
        let decl:Symbol.Decl = `extension`.extended.type
        let scalar:Int32 =
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.decls.append(.init(extensions: []),
                    id: decl)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.decls[decl])
        return scalar
    }
}
extension SSGC.Symbolizer
{
    /// Returns the scalar for the given declaration symbol, registering it in the symbol table
    /// if needed. You should never call ``allocate(decl:)`` or ``allocate(extension:)`` after
    /// calling this function.
    mutating
    func intern(_ id:Symbol.Decl) -> Int32
    {
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.decls.symbols.append(id)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.decls[id])
    }

    /// Returns the scalar for the given file symbol,
    /// registering it in the symbol table if needed.
    mutating
    func intern(_ id:Symbol.File) -> Int32
    {
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.files.append(id)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.files[id])
    }

    mutating
    func intern(_ id:Symbol.Module) -> Int
    {
        {
            switch $0
            {
            case nil:
                let index:Int = self.graph.append(namespace: id)
                $0 = index
                return index

            case let index?:
                return index
            }
        } (&self.modules[id])
    }
    mutating
    func intern(_ id:SSGC.Namespace.ID) -> Int
    {
        switch id
        {
        case .index(let culture):   culture
        case .nominated(let id):    self.intern(id)
        }
    }
}
