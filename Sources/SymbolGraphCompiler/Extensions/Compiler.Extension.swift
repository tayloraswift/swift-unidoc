extension Compiler
{
    @frozen public
    struct Extension
    {
        public
        var conformances:Set<ScalarSymbolResolution>
        public
        var features:Set<ScalarSymbolResolution>
        public
        var members:Set<ScalarSymbolResolution>
        public
        var blocks:[Block]

        public
        let signature:Signature

        init(signature:Signature,
            conformances:Set<ScalarSymbolResolution> = [],
            features:Set<ScalarSymbolResolution> = [],
            members:Set<ScalarSymbolResolution> = [],
            blocks:[Block] = [])
        {
            self.signature = signature

            self.conformances = conformances
            self.features = features
            self.members = members
            self.blocks = blocks
        }
    }
}
