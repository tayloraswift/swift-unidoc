import SymbolGraphParts
import Symbols

extension Compiler
{
    public
    struct Declarations
    {
        private
        let root:Symbol.FileBase?

        private
        var cultures:[Symbol.Module: Int]
        private
        var entries:[Symbol.Decl: Entry]

        init(root:Symbol.FileBase?)
        {
            self.cultures = [:]
            self.entries = [:]
            self.root = root
        }
    }
}
extension Compiler.Declarations
{
    /// Loads all the scalars compiled to far, grouped by culture.
    ///
    /// This function returns one `[Compiler.Namespace]` array in the `local` tuple
    /// component for each time that ``Compiler.compile(culture:parts:)`` was called,
    /// *in the order those calls were originally made*. Within each namespace, the
    /// scalars are sorted alphabetically by mangled name. The namespaces will always
    /// contain at least one scalar.
    ///
    /// The `external` tuple component contains information about foreign symbols
    /// mentioned by the compiled scalars.
    public
    func load() -> (namespaces:[[Compiler.Namespace]], external:Compiler.Nominations)
    {
        var included:[[Compiler.Namespace.ID: [Compiler.Decl]]] = .init(repeating: [:],
            count: self.cultures.count)

        let external:[Symbol.Decl: Compiler.Nomination] =
            self.entries.compactMapValues
        {
            switch $0
            {
            case .included(let reference):
                included[reference.culture][reference.namespace, default: []].append(
                    reference.value)
                return nil

            case .excluded:
                return nil

            case .nominated(let nomination):
                return nomination
            }
        }
        let namespaces:[[Compiler.Namespace]] = included.map
        {
            //  sort scalars by mangled name, and namespaces by id.
            //  do not re-order the cultures themselves; their ordering is significant.
            $0.sorted
            {
                $0.key < $1.key
            }
            .map
            {
                .init(decls: $0.value.sorted { $0.id < $1.id }, id: $0.key)
            }
        }
        return (namespaces, .init(external))
    }
}
extension Compiler.Declarations
{
    mutating
    func include(language:Phylum.Language, culture:Symbol.Module) throws -> Compiler.Culture
    {
        let next:Int = self.cultures.count

        try
        {
            if case nil = $0
            {
                $0 = next
            }
            else
            {
                throw Compiler.DuplicateModuleError.culture(culture)
            }
        }(&self.cultures[culture])

        return .init(id: culture, language: language, index: next, root: self.root)
    }
}
extension Compiler.Declarations
{
    mutating
    func include(scalar symbol:Symbol.Decl,
        namespace:consuming Compiler.Namespace.ID,
        with vertex:SymbolGraphPart.Vertex,
        in culture:Compiler.Culture) throws -> Compiler.DeclObject
    {
        let decl:Compiler.DeclObject = .init(
            conditions: vertex.extension.conditions,
            namespace: namespace,
            culture: culture.index,
            value: try .init(from: vertex,
                as: symbol,
                in: culture))
        try self.update(symbol, with: .included(decl))
        return decl
    }
    mutating
    func include(vector symbol:Symbol.Decl.Vector,
        with vertex:SymbolGraphPart.Vertex) throws
    {
        if  case .decl(let phylum) = vertex.phylum
        {
            { _ in }(&self.entries[symbol.feature,
                default: .nominated(.init(vertex.path.last, phylum: phylum))])
        }
        else
        {
            throw Compiler.UnexpectedSymbolError.vector(symbol)
        }
    }
    mutating
    func exclude(scalar symbol:Symbol.Decl) throws
    {
        try self.update(symbol, with: .excluded)
    }

    private mutating
    func update(_ resolution:Symbol.Decl, with entry:Entry) throws
    {
        try
        {
            switch $0
            {
            case       nil, .nominated?:
                $0 = entry

            case .included?, .excluded?:
                //  if both symbols are C symbols, they are allowed to duplicate
                if  resolution.language == .c ||
                    resolution.suffix.starts(with: "So")
                {
                    return
                }
                else
                {
                    throw Compiler.DuplicateSymbolError.scalar(resolution)
                }
            }
        } (&self.entries[resolution])
    }
}
extension Compiler.Declarations
{
    subscript(namespace namespace:Symbol.Module) -> Compiler.Namespace.ID
    {
        self.cultures[namespace].map(Compiler.Namespace.ID.index(_:)) ?? .nominated(namespace)
    }

    subscript(resolution:Symbol.Decl) -> Symbol.Decl?
    {
        switch self.entries[resolution]
        {
        case .included(let scalar)?:
            scalar.id
        case .excluded?:
            nil
        case .nominated?, nil:
            resolution
        }
    }
    subscript(included resolution:Symbol.Decl) -> Compiler.DeclObject?
    {
        if  case .included(let scalar)? = self.entries[resolution]
        {
            scalar
        }
        else
        {
            nil
        }
    }
    func callAsFunction(
        internal resolution:Symbol.Decl) throws -> Compiler.DeclObject?
    {
        switch self.entries[resolution]
        {
        case .included(let scalar)?:
            return scalar
        case .excluded?:
            return nil
        case .nominated?, nil:
            throw Compiler.UndefinedSymbolError.scalar(resolution)
        }
    }
}
