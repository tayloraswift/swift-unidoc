extension Compiler
{
    public
    struct ExtensionSignature:Hashable, Sendable
    {
        public
        let type:ScalarSymbolResolution
        public
        let conditions:[GenericConstraint<ScalarSymbolResolution>]

        public
        init(_ type:ScalarSymbolResolution,
            where conditions:[GenericConstraint<ScalarSymbolResolution>])
        {
            self.type = type
            self.conditions = conditions
        }
    }
}
