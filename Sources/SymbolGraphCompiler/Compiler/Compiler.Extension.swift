extension Compiler
{
    final
    class Extension:UnqualifiedExtension
    {
        let conditions:[GenericConstraint<ScalarSymbolResolution>]

        init(signature:ExtensionSignature,
            conformances:Set<ScalarSymbolResolution> = [],
            features:Set<ScalarSymbolResolution> = [],
            members:Set<ScalarSymbolResolution> = [],
            blocks:[ExtensionBlock] = [])
        {
            self.conditions = signature.conditions
            super.init(extending: signature.type,
                conformances: conformances,
                features: features,
                members: members,
                blocks: blocks)

            self.conformances = conformances
            self.features = features
            self.members = members
            self.blocks = blocks
        }
    }
}
extension Compiler.Extension
{
    var signature:Compiler.ExtensionSignature
    {
        .init(self.type, where: self.conditions)
    }
}
