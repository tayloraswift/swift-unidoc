import SymbolGraphParts

extension Compiler
{
    public
    struct Scalars
    {
        private
        var recognized:[Symbol.Scalar: Recognition]

        init()
        {
            self.recognized = [:]
        }
    }
}
extension Compiler.Scalars
{
    public
    func load() -> [Compiler.Scalar]
    {
        self.recognized.values.compactMap
        {
            if case .included(let reference) = $0
            {
                return reference.value
            }
            else
            {
                return nil
            }
        }.sorted
        {
            $0.resolution < $1.resolution
        }
    }
}
extension Compiler.Scalars
{
    mutating
    func include(scalar resolution:Symbol.Scalar,
        with description:SymbolDescription,
        in context:Compiler.SourceContext) throws
    {
        try self.recognize(scalar: resolution, as: .included(.init(
            conditions: description.extension.conditions,
            value: .init(from: description,
                as: resolution,
                in: context))))
    }
    mutating
    func exclude(scalar resolution:Symbol.Scalar) throws
    {
        try self.recognize(scalar: resolution, as: .excluded)
    }
    mutating
    func record(scalar resolution:Symbol.Scalar, named name:String) throws
    {
        try self.recognize(scalar: resolution, as: .recorded(name))
    }
    private mutating
    func recognize(scalar resolution:Symbol.Scalar,
        as recognition:Recognition) throws
    {
        switch self.recognized.updateValue(recognition, forKey: resolution)
        {
        case nil, .excluded?, .recorded?:
            return
        
        case .included:
            throw Compiler.DuplicateScalarError.init()
        }
    }
}
extension Compiler.Scalars
{
    subscript(resolution:Symbol.Scalar) -> Symbol.Scalar?
    {
        switch self.recognized[resolution]
        {
        case .included(let scalar)?:
            return scalar.resolution
        case .excluded?:
            return nil
        case .recorded?, nil:
            return resolution
        }
    }
    func callAsFunction(
        internal resolution:Symbol.Scalar) throws -> Compiler.ScalarReference?
    {
        switch self.recognized[resolution]
        {
        case .included(let scalar)?:
            return scalar
        case .excluded?:
            return nil
        case .recorded?, nil:
            throw Compiler.UndefinedScalarError.init(undefined: resolution)
        }
    }
}
