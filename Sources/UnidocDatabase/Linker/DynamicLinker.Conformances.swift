import SymbolGraphs

extension DynamicLinker
{
    struct Conformances
    {
        private
        var signatures:[GlobalAddress: [GlobalSignature]]

        private
        init(signatures:[GlobalAddress: [GlobalSignature]])
        {
            self.signatures = signatures
        }
    }
}
extension DynamicLinker.Conformances:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral:(GlobalAddress, Never)...)
    {
        self.init(signatures: [:])
    }
}
extension DynamicLinker.Conformances
{
    subscript(to protocol:GlobalAddress) -> [GlobalSignature]
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
