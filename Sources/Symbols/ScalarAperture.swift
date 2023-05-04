@frozen public
enum ScalarAperture:UInt8, Equatable, Hashable, Sendable
{
    /// Closed, cannot be overridden (from outside its original module).
    case closed = 0
    /// Open class member (can be overridden).
    case open = 1
    /// Protocol requirement (must be overridden).
    case required = 2
    /// Objective-C optional requirement.
    case requiredOptionally = 3
}
