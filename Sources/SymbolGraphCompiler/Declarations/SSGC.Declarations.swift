import SymbolGraphParts
import Symbols

extension SSGC
{
    public
    struct Declarations
    {
        private
        let threshold:Symbol.ACL

        private
        var table:[Symbol.Decl: DeclObject]
        private
        var holes:[Symbol.Decl: Int]

        init(threshold:Symbol.ACL)
        {
            self.threshold = threshold
            self.table = [:]
            self.holes = [:]
        }
    }
}
extension SSGC.Declarations
{
    /// Loads all the scalars compiled to far, grouped by culture.
    ///
    /// This function returns one `[SSGC.Namespace]` array in the `local` tuple
    /// component for each time that ``Compiler.compile(culture:parts:)`` was called,
    /// *in the order those calls were originally made*. Within each namespace, the
    /// scalars are sorted alphabetically by mangled name. The namespaces will always
    /// contain at least one scalar.
    ///
    /// The `external` tuple component contains information about foreign symbols
    /// mentioned by the compiled scalars.
    // public
    // func load() -> (namespaces:[[SSGC.Namespace]], external:SSGC.Nominations)
    // {
    //     var included:[[SSGC.Namespace.ID: [SSGC.Decl]]] = .init(repeating: [:],
    //         count: self.cultures.count)

    //     let external:[Symbol.Decl: SSGC.Nomination] = self.entries.compactMapValues
    //     {
    //         switch $0
    //         {
    //         case .included(let reference):
    //             included[reference.culture][reference.namespace, default: []].append(
    //                 reference.value)
    //             return nil

    //         case .excluded:
    //             return nil

    //         case .nominated(let nomination):
    //             return nomination
    //         }
    //     }
    //     let namespaces:[[SSGC.Namespace]] = included.map
    //     {
    //         //  sort scalars by mangled name, and namespaces by id.
    //         //  do not re-order the cultures themselves; their ordering is significant.
    //         $0.sorted
    //         {
    //             $0.key < $1.key
    //         }
    //         .map
    //         {
    //             .init(decls: $0.value.sorted { $0.id < $1.id }, id: $0.key)
    //         }
    //     }
    //     return (namespaces, .init(external))
    // }
}
extension SSGC.Declarations
{
    mutating
    func include(_ vertex:SymbolGraphPart.Vertex,
        namespace:Symbol.Module,
        culture:Symbol.Module) -> SSGC.DeclObject
    {
        guard
        case .scalar(let symbol) = vertex.usr,
        case .decl(let phylum) = vertex.phylum
        else
        {
            fatalError("vertex is not a decl!")
        }

        let decl:SSGC.DeclObject =
        {
            if  let decl:SSGC.DeclObject = $0
            {
                return decl
            }

            var kinks:Phylum.Decl.Kinks = []
            //  It’s not like we should ever see a vertex that is both `final` and `open`, but
            //  who knows what bugs exist in lib/SymbolGraphGen.
            if  vertex.final
            {
                kinks[is: .final] = true
            }
            else if case .open = vertex.acl
            {
                kinks[is: .open] = true
            }

            let decl:SSGC.DeclObject = .init(
                conditions: vertex.extension.conditions,
                namespace: namespace,
                culture: culture,
                access: vertex.acl,
                value: .init(id: symbol,
                    signature: vertex.signature,
                    location: vertex.location,
                    phylum: phylum,
                    path: vertex.path,
                    kinks: kinks,
                    comment: vertex.doccomment.map { .init($0.text, at: $0.start) } ?? nil))

            $0 = decl
            return decl

        } (&self.table[symbol])

        return decl
    }
}
extension SSGC.Declarations
{
    /// Loads the declaration object for the specified symbol, throwing an error if the
    /// declaration does not exist.
    subscript(id:Symbol.Decl) -> SSGC.DeclObject
    {
        get throws
        {
            if  let decl:SSGC.DeclObject = self.table[id]
            {
                return decl
            }
            else
            {
                throw SSGC.UndefinedSymbolError.scalar(id)
            }
        }
    }

    /// Loads the declaration object for the specified symbol, returning `nil` if the
    /// declaration does not exist, or if the declaration does not have visibility of at least
    /// ``threshold``. If the declaration does not exist, the missing symbol is logged within
    /// this structure.
    ///
    /// It is expected that a small number of symbols will be missing, even with pre-validation,
    /// due to certain quirks of lib/SymbolGraphGen.
    subscript(visible id:Symbol.Decl) -> SSGC.DeclObject?
    {
        mutating get
        {
            guard
            let decl:SSGC.DeclObject = self.table[id]
            else
            {
                self.holes[id, default: 0] += 1
                return nil
            }

            if  decl.access < self.threshold
            {
                return nil
            }
            else
            {
                return decl
            }
        }
    }
}
/*
extension SSGC.Declarations
{
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
    subscript(included resolution:Symbol.Decl) -> SSGC.DeclObject?
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
    func callAsFunction(internal resolution:Symbol.Decl) throws -> SSGC.DeclObject?
    {
        switch self.entries[resolution]
        {
        case .included(let scalar)?:
            return scalar
        case .excluded?:
            return nil
        case .nominated?, nil:
            throw SSGC.UndefinedSymbolError.scalar(resolution)
        }
    }
}
*/
