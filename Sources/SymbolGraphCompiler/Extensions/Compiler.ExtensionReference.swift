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
    var extendee:ScalarSymbolResolution
    {
        self.value.signature.type
    }
    var conditions:[GenericConstraint<ScalarSymbolResolution>]?
    {
        self.value.signature.conditions
    }

    func insert(conformance:ScalarSymbolResolution)
    {
        self.value.conformances.insert(conformance)
    }
    func insert(feature:ScalarSymbolResolution)
    {
        self.value.features.insert(feature)
    }
    func insert(member:ScalarSymbolResolution)
    {
        self.value.members.insert(member)
    }

    func append(block:Compiler.Extension.Block)
    {
        self.value.blocks.append(block)
    }
}
