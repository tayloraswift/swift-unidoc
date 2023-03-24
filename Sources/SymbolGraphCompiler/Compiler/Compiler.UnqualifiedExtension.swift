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
