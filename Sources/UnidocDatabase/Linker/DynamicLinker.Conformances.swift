import Unidoc

extension DynamicLinker
{
    struct Conformances
    {
        private
        var signatures:[Unidoc.Scalar: [ExtensionSignature]]

        private
        init(signatures:[Unidoc.Scalar: [ExtensionSignature]])
        {
            self.signatures = signatures
        }
    }
}
extension DynamicLinker.Conformances:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral:(Unidoc.Scalar, Never)...)
    {
        self.init(signatures: [:])
    }
}
extension DynamicLinker.Conformances
{
    subscript(to protocol:Unidoc.Scalar) -> [ExtensionSignature]
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
