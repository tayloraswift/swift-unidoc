import SymbolColonies

extension Compiler
{
    struct Scalars
    {
        private
        var recognized:[ScalarSymbolResolution: Recognition]

        init()
        {
            self.recognized = [:]
        }
    }
}
extension Compiler.Scalars
{
    mutating
    func exclude(scalar resolution:ScalarSymbolResolution) throws
    {
        try self.recognize(scalar: resolution, as: .excluded)
    }
    mutating
    func include(scalar resolution:ScalarSymbolResolution,
        with description:SymbolDescription,
        in culture:ModuleIdentifier) throws
    {
        try self.recognize(scalar: resolution, as: .included(.init(from: description,
            as: resolution,
            in: culture)))
    }
    private mutating
    func recognize(scalar resolution:ScalarSymbolResolution,
        as recognition:Recognition) throws
    {
        switch self.recognized.updateValue(recognition, forKey: resolution)
        {
        case nil, .excluded?:
            return
        
        case .included:
            throw Compiler.DuplicateScalarError.init()
        }
    }
}
extension Compiler.Scalars
{
    subscript(resolution:ScalarSymbolResolution) -> ScalarSymbolResolution?
    {
        switch self.recognized[resolution]
        {
        case .included(let scalar)?:
            return scalar.resolution
        case .excluded?:
            return nil
        case nil:
            return resolution
        }
    }
    func callAsFunction(internal resolution:ScalarSymbolResolution) throws -> Compiler.Scalar?
    {
        switch self.recognized[resolution]
        {
        case .included(let scalar)?:
            return scalar
        case .excluded?:
            return nil
        case nil:
            throw Compiler.ScalarReferenceError.external(resolution)
        }
    }
}
