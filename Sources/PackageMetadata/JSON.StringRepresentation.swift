import JSONDecoding
import JSONEncoding

extension JSON
{
    /// Decodes or encodes a type that normally uses a different coding scheme
    /// by using its string representation instead. This is here and not in the
    /// main JSON library, because only SwiftPM uses these demented schema.
    struct StringRepresentation<Value> where Value:LosslessStringConvertible
    {
        public
        let value:Value

        @inlinable public
        init(_ value:Value)
        {
            self.value = value
        }
    }
}
extension JSON.StringRepresentation:LosslessStringConvertible, CustomStringConvertible
{
    init?(_ description:String)
    {
        if let value:Value = .init(description)
        {
            self.init(value)
        }
        else
        {
            return nil
        }
    }
    var description:String
    {
        self.value.description
    }
}
extension JSON.StringRepresentation:JSONStringDecodable, JSONStringEncodable
{
}
