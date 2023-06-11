import SymbolGraphs

extension DynamicLinker
{
    struct Extensions
    {
        private
        var projections:[GlobalSignature: ExtensionProjection]

        private
        init(projections:[GlobalSignature: ExtensionProjection])
        {
            self.projections = projections
        }
    }
}
extension DynamicLinker.Extensions:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral:(GlobalAddress, Never)...)
    {
        self.init(projections: [:])
    }
}
extension DynamicLinker.Extensions
{
    subscript(signature:GlobalSignature) -> ExtensionProjection
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
