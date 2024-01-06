import BSON
import Signatures

extension Unidoc
{
    @frozen public
    struct ConformingType:Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        let constraints:[GenericConstraint<Unidoc.Scalar?>]

        @inlinable public
        init(id:Unidoc.Scalar, where constraints:[GenericConstraint<Unidoc.Scalar?>] = [])
        {
            self.id = id
            self.constraints = constraints
        }
    }
}
extension Unidoc.ConformingType
{
    @inlinable
    var conditional:Conditional?
    {
        self.constraints.isEmpty ? nil : .init(id: self.id, where: self.constraints)
    }
}
extension Unidoc.ConformingType:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        if  let conditional:Conditional = self.conditional
        {
            conditional.encode(to: &field)
        }
        else
        {
            self.id.encode(to: &field)
        }
    }
}
extension Unidoc.ConformingType:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        if  case .id(let id) = bson
        {
            self.init(id: Unidoc.Scalar.init(id))
        }
        else
        {
            let conditional:Conditional = try .init(bson: bson)
            self.init(id: conditional.id, where: conditional.constraints)
        }
    }
}
