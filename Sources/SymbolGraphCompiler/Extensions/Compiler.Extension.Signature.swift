extension Compiler.Extension
{
    @frozen public
    struct Signature:Equatable, Hashable, Sendable
    {
        /// The type extended by the relevant extension group.
        public
        let type:ScalarSymbolResolution
        /// The generic constraints of the relevant this extension group.
        /// An empty array indicates an unconstrained extension, while
        /// nil indicates an unknown or inapplicable generic context.
        public
        let conditions:[GenericConstraint<ScalarSymbolResolution>]?

        public
        init(_ type:ScalarSymbolResolution,
            where conditions:[GenericConstraint<ScalarSymbolResolution>]?)
        {
            self.type = type
            self.conditions = conditions
        }
    }
}
