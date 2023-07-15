extension Unidoc.Decl
{
    @frozen public
    enum Customization:UInt8, Equatable, Hashable, Sendable
    {
        /// Cannot be overridden (from outside its original module).
        case unavailable = 0
        /// Can be overridden (open class member).
        case available = 1
        /// Protocol requirement (must be overridden).
        case required = 2
        /// Objective-C optional requirement.
        case requiredOptionally = 3
    }
}
