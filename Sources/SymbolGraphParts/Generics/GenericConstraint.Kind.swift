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
    func callAsFunction(_ name:String,
        is type:GenericConstraint<Scalar>.TypeExpression) -> GenericConstraint<Scalar>
    {
        switch self
        {
        case .conformance:  return .init(name, is: .conformer(of: type))
        case .superclass:   return .init(name, is: .subclass(of: type))
        case .sameType:     return .init(name, is: .type(type))
        }
    }
}
