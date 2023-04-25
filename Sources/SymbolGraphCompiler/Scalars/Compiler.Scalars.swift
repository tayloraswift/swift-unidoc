import LexicalPaths
import SymbolGraphParts

extension Compiler
{
    public
    struct Scalars
    {
        private
        var entries:[Symbol.Scalar: Entry]

        init()
        {
            self.entries = [:]
        }
    }
}
extension Compiler.Scalars
{
    public
    func load() -> (local:[Compiler.Scalar], external:External)
    {
        var included:[Compiler.Scalar] = []
        let external:[Symbol.Scalar: Compiler.ScalarNomination] =
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

        return (included.sorted { $0.resolution < $1.resolution }, .init(external))
    }
}
extension Compiler.Scalars
{
    mutating
    func include(vector resolution:Symbol.Vector, with description:SymbolDescription) throws
    {
        guard case .scalar(let phylum) = description.phylum
        else
        {
            throw Compiler.SymbolError.init(invalid: .vector(resolution))
        }

        ({ _ in })(&self.entries[resolution.heir,
            default: .nominated(.heir(description.path.prefix))])
        
        ({ _ in })(&self.entries[resolution.feature,
            default: .nominated(.feature(description.path.last, phylum))])
    }
    mutating
    func include(scalar resolution:Symbol.Scalar,
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
    func exclude(scalar resolution:Symbol.Scalar) throws
    {
        try self.update(resolution, with: .excluded)
    }

    private mutating
    func update(_ resolution:Symbol.Scalar, with entry:Entry) throws
    {
        try
        {
            switch $0
            {
            case       nil, .nominated?: $0 = entry
            case .included?, .excluded?: throw Compiler.DuplicateScalarError.init()
            }
        } (&self.entries[resolution])
    }
}
extension Compiler.Scalars
{
    subscript(resolution:Symbol.Scalar) -> Symbol.Scalar?
    {
        switch self.entries[resolution]
        {
        case .included(let scalar)?:
            return scalar.resolution
        case .excluded?:
            return nil
        case .nominated?, nil:
            return resolution
        }
    }
    func callAsFunction(
        internal resolution:Symbol.Scalar) throws -> Compiler.ScalarReference?
    {
        switch self.entries[resolution]
        {
        case .included(let scalar)?:
            return scalar
        case .excluded?:
            return nil
        case .nominated?, nil:
            throw Compiler.UndefinedScalarError.init(undefined: resolution)
        }
    }
}
