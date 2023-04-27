import Codelinks
import Generics

extension SymbolGraph
{
    @frozen public
    struct Extension
    {
        public
        let conditions:[GenericConstraint<ScalarAddress>]

        public
        var conformances:[ScalarAddress]
        /// Members the extended type inherits from other types via subclassing,
        /// protocol conformances, etc.
        public
        var features:[ScalarAddress]
        /// Declarations directly nested in the extended type. Everything that
        /// is lexically-scoped to the extended type, and was not inherited from
        /// another type goes in this set.
        public
        var nested:[ScalarAddress]

        public
        var bytecode:[UInt8]
        public
        var links:[Codelink]

        @inlinable public
        init(conformances:[ScalarAddress] = [],
            features:[ScalarAddress] = [],
            nested:[ScalarAddress] = [],
            where conditions:[GenericConstraint<ScalarAddress>] = [])
        {
            self.conditions = conditions

            self.conformances = conformances
            self.features = features
            self.nested = nested

            self.bytecode = []
            self.links = []
        }
    }
}
