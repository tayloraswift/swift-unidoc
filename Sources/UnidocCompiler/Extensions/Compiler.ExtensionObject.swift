import Generics
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
    var signature:Compiler.Extension.Signature
    {
        self.value.signature
    }
    var extendee:ScalarSymbol
    {
        self.value.extendee
    }
    var conditions:[GenericConstraint<ScalarSymbol>]
    {
        self.value.conditions
    }

    func add(conformance:ScalarSymbol)
    {
        self.value.conformances.insert(conformance)
    }
    func add(feature:ScalarSymbol)
    {
        self.value.features.insert(feature)
    }
    func add(nested:ScalarSymbol)
    {
        self.value.nested.insert(nested)
    }

    func append(block:Compiler.Extension.Block)
    {
        self.value.blocks.append(block)
    }
}
