extension Unidoc.Decl
{
    @frozen public
    enum Kink:UInt8, Equatable, Hashable, Sendable
    {
        /// Can be overridden from outside its original module.
        case open                   = 0b0000_0001
        /// Overrides a superclass member, or a supertype requirement.
        case override               = 0b0000_0010
        /// Required by a protocol.
        case required               = 0b0000_0100
        /// Required by a protocol, optionally. Implies ``required``.
        case requiredOptionally     = 0b0000_1100
        /// Universal witness for at least one protocol requirement.
        case intrinsicWitness       = 0b0001_0000
        /// Has at least one universal witness from the same package.
        case implemented            = 0b0010_0000
    }
}
