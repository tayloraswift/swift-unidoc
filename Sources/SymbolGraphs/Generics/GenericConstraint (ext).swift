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
    enum CodingKey:String, Sendable
    {
        case generic = "G"
        case nominal = "N"
        case complex = "C"
    }
}
extension GenericConstraint:BSONDocumentEncodable, BSONEncodable
    where Scalar:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        let sigil:Sigil
        switch self.what
        {
        case .conformer:    sigil = .conformer
        case .subclass:     sigil = .subclass
        case .equal:        sigil = .equal
        }

        bson[.generic] = "\(sigil)\(self.noun)"

        switch self.whom
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
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKey, Bytes>) throws
    {
        let (sigil, noun):(Sigil, String) = try bson[.generic].decode(
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

        let type:GenericType<Scalar>
        //  If there is a null value (which is allowed if `Scalar` is an ``Optional`` type),
        //  we don’t want to attempt to decode from ``CodingKey.complex``. If we do not
        //  specify the decoded type (`Scalar.self`), the compiler will infer it to be
        //  `Scalar?`, which will cause us to fall through to the else block!
        if  let scalar:Scalar = try bson[.nominal]?.decode(to: Scalar.self)
        {
            type = .nominal(scalar)
        }
        else
        {
            type = .complex(try bson[.complex].decode())
        }

        switch sigil
        {
        case .conformer:    self = .where(noun, is: .conformer, to: type)
        case .subclass:     self = .where(noun, is: .subclass, to: type)
        case .equal:        self = .where(noun, is: .equal, to: type)
        }
    }
}
