import SymbolGraphs

extension DynamicLinker
{
    struct Conformances
    {
        private
        var signatures:[Scalar96: [ExtensionSignature]]

        private
        init(signatures:[Scalar96: [ExtensionSignature]])
        {
            self.signatures = signatures
        }
    }
}
extension DynamicLinker.Conformances:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral:(Scalar96, Never)...)
    {
        self.init(signatures: [:])
    }
}
extension DynamicLinker.Conformances
{
    subscript(to protocol:Scalar96) -> [ExtensionSignature]
    {
        _read
        {
            yield  self.signatures[`protocol`, default: []]
        }
        _modify
        {
            yield &self.signatures[`protocol`, default: []]
        }
    }
}
