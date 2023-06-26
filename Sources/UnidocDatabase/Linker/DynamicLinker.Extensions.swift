import SymbolGraphs

extension DynamicLinker
{
    struct Extensions
    {
        private
        var projections:[ExtensionSignature: ExtensionProjection]

        private
        init(projections:[ExtensionSignature: ExtensionProjection])
        {
            self.projections = projections
        }
    }
}
extension DynamicLinker.Extensions:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral:(Scalar96, Never)...)
    {
        self.init(projections: [:])
    }
}
extension DynamicLinker.Extensions
{
    subscript(signature:ExtensionSignature) -> ExtensionProjection
    {
        _read
        {
            yield  self.projections[signature, default: .init(signature: signature)]
        }
        _modify
        {
            yield &self.projections[signature, default: .init(signature: signature)]
        }
    }
}
