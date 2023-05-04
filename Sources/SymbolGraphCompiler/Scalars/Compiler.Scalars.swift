import LexicalPaths
import SymbolGraphParts

extension Compiler
{
    public
    struct Scalars
    {
        private
        var entries:[ScalarSymbol: Entry]

        init()
        {
            self.entries = [:]
        }
    }
}
extension Compiler.Scalars
{
    public
    func load() -> (local:[Compiler.Scalar], external:Compiler.ScalarNominations)
    {
        var included:[Compiler.Scalar] = []
        let external:[ScalarSymbol: Compiler.ScalarNomination] =
            self.entries.compactMapValues
        {
            switch $0
            {
            case .included(let reference):
                included.append(reference.value)
                return nil
            
            case .excluded:
                return nil
            
            case .nominated(let nomination):
                return nomination
            }
        }

        return (included.sorted { $0.id < $1.id }, .init(external))
    }
}
extension Compiler.Scalars
{
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
        in context:Compiler.SourceContext) throws
    {
        try self.update(resolution, with: .included(.init(
            conditions: description.extension.conditions,
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
        internal resolution:ScalarSymbol) throws -> Compiler.ScalarReference?
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
