import LexicalPaths
import ModuleGraphs
import Symbols
import SymbolGraphParts

extension Compiler
{
    public
    struct Declarations
    {
        private
        var cultures:[ModuleIdentifier: Int]
        private
        var entries:[Symbol.Decl: Entry]
        private
        let root:Repository.Root?

        init(root:Repository.Root?)
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
    func include(culture:ModuleIdentifier) throws -> Compiler.Culture
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

        return .init(id: culture, index: next, root: self.root)
    }
}
extension Compiler.Declarations
{
    mutating
    func include(vector resolution:Symbol.Decl.Vector,
        with description:SymbolDescription) throws
    {
        if  case .decl(let phylum) = description.phylum
        {
            { _ in }(&self.entries[resolution.feature,
                default: .nominated(.init(description.path.last, phylum: phylum))])
        }
        else
        {
            throw Compiler.UnexpectedSymbolError.vector(resolution)
        }
    }
    mutating
    func include(scalar resolution:Symbol.Decl,
        namespace:__owned Compiler.Namespace.ID,
        with description:SymbolDescription,
        in culture:Compiler.Culture) throws
    {
        try self.update(resolution, with: .included(.init(
            conditions: description.extension.conditions,
            namespace: namespace,
            culture: culture.index,
            value: .init(from: description,
                as: resolution,
                in: culture))))
    }
    mutating
    func exclude(scalar resolution:Symbol.Decl) throws
    {
        try self.update(resolution, with: .excluded)
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
                if  resolution.language == "c" ||
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
    subscript(namespace namespace:ModuleIdentifier) -> Compiler.Namespace.ID
    {
        self.cultures[namespace].map(Compiler.Namespace.ID.index(_:)) ?? .nominated(namespace)
    }

    subscript(resolution:Symbol.Decl) -> Symbol.Decl?
    {
        switch self.entries[resolution]
        {
        case .included(let scalar)?:
            return scalar.id
        case .excluded?:
            return nil
        case .nominated?, nil:
            return resolution
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
