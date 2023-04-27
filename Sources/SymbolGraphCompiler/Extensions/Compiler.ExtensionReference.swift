import Generics

extension Compiler
{
    class ExtensionReference
    {
        final private(set)
        var value:Extension

        init(value:Extension)
        {
            self.value = value
        }
    }
}
extension Compiler.ExtensionReference
{
    var signature:Compiler.Extension.Signature
    {
        self.value.signature
    }
    var extendee:Symbol.Scalar
    {
        self.value.extendee
    }
    var conditions:[GenericConstraint<Symbol.Scalar>]
    {
        self.value.conditions
    }

    func add(conformance:Symbol.Scalar)
    {
        self.value.conformances.insert(conformance)
    }
    func add(feature:Symbol.Scalar)
    {
        self.value.features.insert(feature)
    }
    func add(nested:Symbol.Scalar)
    {
        self.value.nested.insert(nested)
    }

    func append(block:Compiler.Extension.Block)
    {
        self.value.blocks.append(block)
    }
}
