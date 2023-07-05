import Signatures
import Symbols

extension Compiler
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
extension Compiler.ExtensionObject
{
    var signature:Compiler.ExtensionSignature
    {
        self.value.signature
    }
    var extended:Compiler.ExtendedType
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

    func append(block:Compiler.Extension.Block)
    {
        self.value.blocks.append(block)
    }
}
