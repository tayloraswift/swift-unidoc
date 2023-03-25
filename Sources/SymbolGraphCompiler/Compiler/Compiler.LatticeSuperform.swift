extension Compiler
{
    enum LatticeSuperform:Equatable, Hashable, Sendable
    {
        /// The protocol requirement this protocol leaf member is a
        /// default implementation of, if the relevant scalar is a
        /// leaf member.
        case implements(ScalarSymbolResolution)
        /// The protocol requirement this leaf scalar overrides, if
        /// the relevant scalar is a leaf requirement, or the class
        /// member this leaf scalar overrides, if the relevant scalar
        /// is a leaf member.
        case overrides(ScalarSymbolResolution)
        /// The protocol this protocol inherits from, if the relevant
        /// scalar is a protocol, or the class this class subclasses,
        /// if the relevant scalar is a class.
        case inherits(ScalarSymbolResolution)
    }
}
