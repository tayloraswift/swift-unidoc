import Signatures
import Symbols

extension SSGC
{
    final
    class ExtensionObject
    {
        private(set)
        var value:Extension

        init(value:Extension)
        {
            self.value = value
        }
    }
}
extension SSGC.ExtensionObject
{
    var signature:SSGC.ExtensionSignature
    {
        self.value.signature
    }
    var extended:SSGC.ExtendedType
    {
        self.value.extended
    }
    var conditions:[GenericConstraint<Symbol.Decl>]
    {
        self.value.conditions
    }

    func add(conformance:Symbol.Decl)
    {
        self.value.conformances.insert(conformance)
    }
    func add(feature:Symbol.Decl)
    {
        self.value.features.insert(feature)
    }
    func add(nested:Symbol.Decl)
    {
        self.value.nested.insert(nested)
    }

    func append(block:SSGC.Extension.Block)
    {
        self.value.blocks.append(block)
    }
}
