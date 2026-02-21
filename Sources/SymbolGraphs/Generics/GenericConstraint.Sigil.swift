import Signatures

extension GenericConstraint {
    @frozen public enum Sigil: Unicode.Scalar {
        case conformer  = "0"
        case subclass   = "1"
        case equal      = "2"
    }
}
extension GenericConstraint.Sigil: CustomStringConvertible {
    @inlinable public var description: String { "\(self.rawValue)" }
}
