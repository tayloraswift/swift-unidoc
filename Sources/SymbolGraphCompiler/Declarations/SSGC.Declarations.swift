import Signatures
import SymbolGraphParts
import Symbols

extension SSGC
{
    struct Declarations
    {
        private
        let threshold:Symbol.ACL

        private
        var decls:[Symbol.Decl: DeclObject]
        private
        var holes:[Symbol.Decl: Int]

        init(threshold:Symbol.ACL)
        {
            self.threshold = threshold
            self.decls = [:]
            self.holes = [:]
        }
    }
}
extension SSGC.Declarations
{
    var all:LazyFilterSequence<Dictionary<Symbol.Decl, SSGC.DeclObject>.Values>
    {
        self.decls.values.lazy.filter { $0.access >= self.threshold }
    }
}
extension SSGC.Declarations
{
    /// Returns the declaration object, or nil if it has already been indexed, or does not meet
    /// the minimum visibility threshold.
    mutating
    func include(_ vertex:SymbolGraphPart.Vertex,
        namespace:Symbol.Module,
        culture:Symbol.Module) -> SSGC.DeclObject?
    {
        guard
        case .scalar(let symbol) = vertex.usr,
        case .decl(let phylum) = vertex.phylum
        else
        {
            fatalError("vertex is not a decl!")
        }

        let decl:SSGC.DeclObject? =
        {
            if  let reexported:SSGC.DeclObject = $0
            {
                //  We have already indexed this declaration!
                if  reexported.namespace != namespace
                {
                    reexported.namespaces.insert(namespace)
                }

                return nil
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

            /// Note that the universal conditions are not guaranteed to be in any particular
            /// order, so modeling them as a set loses no information.
            let decl:SSGC.DeclObject = .init(
                conditions: Set.init(vertex.extension.conditions),
                namespace: namespace,
                culture: culture,
                access: vertex.acl,
                value: .init(id: symbol,
                    signature: vertex.signature,
                    autograph: vertex.autograph,
                    location: vertex.location,
                    phylum: phylum,
                    path: vertex.path,
                    kinks: kinks,
                    comment: vertex.doccomment.map { .init($0.text, at: $0.start) } ?? nil))

            $0 = decl
            return decl.access < self.threshold ? nil : decl

        } (&self.decls[symbol])

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
            if  let decl:SSGC.DeclObject = self.decls[id]
            {
                return decl
            }
            else
            {
                throw SSGC.UndefinedSymbolError.declaration(id)
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
            let decl:SSGC.DeclObject = self.decls[id]
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
extension SSGC.Declarations
{
    /// Loads all the scalars belonging to the specified culture that have been compiled so far.
    ///
    /// Within each namespace, the declarations are sorted alphabetically by mangled name. The
    /// namespaces will always contain at least one scalar.
    func load(culture:Symbol.Module) -> [(Symbol.Module, [SSGC.Decl])]
    {
        let included:[Symbol.Module: [SSGC.Decl]] = self.decls.values.reduce(into: [:])
        {
            guard $1.access >= self.threshold, $1.culture == culture
            else
            {
                return
            }

            var decl:SSGC.Decl = $1.value

            //  Strip duplicated doccomments
            if  let documentationComment:SSGC.DocumentationComment = decl.comment
            {
                for origin:Symbol.Decl in decl.origins
                {
                    if  let origin:SSGC.Decl = self.decls[origin]?.value,
                        let originComment:SSGC.DocumentationComment = origin.comment,
                            originComment.text == documentationComment.text
                    {
                        decl.comment = nil
                    }
                }
            }

            $0[$1.namespace, default: []].append(decl)
        }

        var namespaces:[(Symbol.Module, [SSGC.Decl])] = included.sorted
        {
            $0.key < $1.key
        }
        for i:Int in namespaces.indices
        {
            namespaces[i].1.sort { $0.id < $1.id }
        }

        return namespaces
    }
}
