extension Compiler
{
    class UnqualifiedExtension
    {
        final
        var conformances:Set<ScalarSymbolResolution>
        final
        var features:Set<ScalarSymbolResolution>
        final
        var members:Set<ScalarSymbolResolution>
        final
        var blocks:[ExtensionBlock]

        final
        let type:ScalarSymbolResolution

        init(extending type:ScalarSymbolResolution,
            conformances:Set<ScalarSymbolResolution> = [],
            features:Set<ScalarSymbolResolution> = [],
            members:Set<ScalarSymbolResolution> = [],
            blocks:[ExtensionBlock] = [])
        {
            self.type = type

            self.conformances = conformances
            self.features = features
            self.members = members
            self.blocks = blocks
        }
    }
}
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

// import SymbolColonies
// extension Compiler
// {
//     struct ExtensionRelationships
//     {
//         private
//         let object:Compiler.Extension

//         init(_ object:Compiler.Extension)
//         {
//             self.object = object
//         }
//     }
// }

// extension Compiler.ExtensionRelationships
// {
//     var conformances:Set<SymbolIdentifier>
//     {
//         _read
//         {
//             yield  self.object.conformances
//         }
//         _modify
//         {
//             yield &self.object.conformances
//         }
//     }
//     var features:Set<SymbolIdentifier>
//     {
//         _read
//         {
//             yield  self.object.features
//         }
//         _modify
//         {
//             yield &self.object.features
//         }
//     }
//     var members:Set<SymbolIdentifier>
//     {
//         _read
//         {
//             yield  self.object.members
//         }
//         _modify
//         {
//             yield &self.object.members
//         }
//     }
// }
