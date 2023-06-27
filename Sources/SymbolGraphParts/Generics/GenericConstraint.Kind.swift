import JSONDecoding
import JSONEncoding
import Signatures

extension GenericConstraint
{
    enum Kind:String, JSONDecodable, JSONEncodable
    {
        case conformance
        case superclass
        case sameType
    }
}
extension GenericConstraint.Kind
{
    var `operator`:GenericOperator
    {
        switch self
        {
        case .conformance:  return .conformer
        case .superclass:   return .subclass
        case .sameType:     return .equal
        }
    }
}
