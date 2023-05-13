import LexicalPaths
import PackageGraphs
import Symbols
import SymbolGraphParts

extension Compiler
{
    public
    struct Scalars
    {
        private
        var entries:[ScalarSymbol: Entry]
        private
        var modules:[ModuleIdentifier]

        private
        let root:Repository.Root?

        init(root:Repository.Root?)
        {
            self.entries = [:]
            self.modules = []

            self.root = root
        }
    }
}
extension Compiler.Scalars
{
    public
    func load() -> (local:[Compiler.Culture], external:Compiler.Nominations)
    {
        var included:[Compiler.Culture] = self.modules.map(Compiler.Culture.init(id:))
        let external:[ScalarSymbol: Compiler.Nomination] =
            self.entries.compactMapValues
        {
            switch $0
            {
            case .included(let reference):
                included[reference.culture].scalars.append(reference.value)
                return nil

            case .excluded:
                return nil

            case .nominated(let nomination):
                return nomination
            }
        }
        //  sort scalars by mangled name. do not re-order the cultures themselves;
        //  their ordering is significant.
        for culture:Int in included.indices
        {
            included[culture].scalars.sort { $0.id < $1.id }
        }

        return (included, .init(external))
    }
}
extension Compiler.Scalars
{
    mutating
    func include(culture:ModuleIdentifier) -> Compiler.Context
    {
        defer
        {
            self.modules.append(culture)
        }
        return .init(culture: (id: culture, index: self.modules.endIndex), root: self.root)
    }
    mutating
    func include(vector resolution:VectorSymbol, with description:SymbolDescription) throws
    {
        if case .scalar(let phylum) = description.phylum
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
    func include(scalar resolution:ScalarSymbol,
        with description:SymbolDescription,
        in context:Compiler.Context) throws
    {
        try self.update(resolution, with: .included(.init(
            conditions: description.extension.conditions,
            culture: context.culture.index,
            value: .init(from: description,
                as: resolution,
                in: context))))
    }
    mutating
    func exclude(scalar resolution:ScalarSymbol) throws
    {
        try self.update(resolution, with: .excluded)
    }

    private mutating
    func update(_ resolution:ScalarSymbol, with entry:Entry) throws
    {
        try
        {
            switch $0
            {
            case       nil, .nominated?: $0 = entry
            case .included?, .excluded?: throw Compiler.DuplicateSymbolError.scalar(resolution)
            }
        } (&self.entries[resolution])
    }
}
extension Compiler.Scalars
{
    subscript(resolution:ScalarSymbol) -> ScalarSymbol?
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
        internal resolution:ScalarSymbol) throws -> Compiler.ScalarObject?
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
