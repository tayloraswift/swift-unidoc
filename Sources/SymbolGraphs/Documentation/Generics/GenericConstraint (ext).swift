import BSONDecoding
import BSONEncoding
import Signatures

extension GenericConstraint
{
    /// Single-letter coding keys for compact generic constraint
    /// representations in BSON.
    ///
    /// The BSON coding schema looks roughly like one of
    ///
    /// `{ G: "0GenericParameterName.AssociatedType", N: 0x1234_5678 }`
    ///
    /// or
    ///
    /// `{ G: "0GenericParameterName.AssociatedType", C: "Array<Int>" }` .
    ///
    /// The nominal (`N`) field is usually integer-typed, but its BSON
    /// representation is up to the generic ``Scalar`` parameter.
    ///
    /// The complex (`C`) field is always a string.
    @frozen public
    enum CodingKeys:String
    {
        case generic = "G"
        case nominal = "N"
        case complex = "C"
    }
}
extension GenericConstraint:BSONDocumentEncodable, BSONEncodable, BSONWeakEncodable
    where Scalar:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        let expression:TypeExpression
        let sigil:Sigil
        switch self.is
        {
        case .conformer(of: let rhs):
            expression = rhs
            sigil = .conformer
        case .subclass(of: let rhs):
            expression = rhs
            sigil = .subclass
        case .type(let rhs):
            expression = rhs
            sigil = .type
        }

        bson[.generic] = "\(sigil.rawValue)\(self.name)"

        switch expression
        {
        case .nominal(let type):        bson[.nominal] = type
        case .complex(let description): bson[.complex] = description
        }
    }
}
extension GenericConstraint:BSONDocumentDecodable, BSONDecodable, BSONDocumentViewDecodable
    where Scalar:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKeys, Bytes>) throws
    {
        let (sigil, name):(Sigil, String) = try bson[.generic].decode(
            as: BSON.UTF8View<Bytes.SubSequence>.self)
        {
            guard let sigil:Unicode.Scalar = $0.slice.first.map(Unicode.Scalar.init(_:))
            else
            {
                throw SigilError.init()
            }
            guard let sigil:Sigil = .init(rawValue: sigil)
            else
            {
                throw SigilError.init(invalid: sigil)
            }

            return (sigil, .init(decoding: $0.slice.dropFirst(), as: Unicode.UTF8.self))
        }
        let expression:TypeExpression
        if  let type:Scalar = try bson[.nominal]?.decode()
        {
            expression = .nominal(type)
        }
        else
        {
            expression = .complex(try bson[.complex].decode())
        }

        switch sigil
        {
        case .conformer:    self.init(name, is: .conformer(of: expression))
        case .subclass:     self.init(name, is: .subclass(of: expression))
        case .type:         self.init(name, is: .type(expression))
        }
    }
}
