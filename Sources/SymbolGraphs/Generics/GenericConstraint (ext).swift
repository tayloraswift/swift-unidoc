import BSON
import Signatures

extension GenericConstraint
{
    /// Single-letter coding keys for compact generic constraint
    /// representations in BSON.
    ///
    /// The BSON coding schema looks roughly like one of
    ///
    /// `{ G: "0GenericParameterName.AssociatedType", C: "Int", N: 0x1234_5678 }`
    ///
    /// or
    ///
    /// `{ G: "0GenericParameterName.AssociatedType", C: "Array<Int>" }` .
    ///
    /// The ``nominal`` (`N`) field is usually integer-typed, but its BSON
    /// representation is up to the generic `Scalar` parameter.
    ///
    /// The ``spelling`` (`C`) field is always a string.
    ///
    /// Prior to 0.9.9, the ``spelling`` was optional.
    @frozen public
    enum CodingKey:String, Sendable
    {
        case generic = "G"
        case nominal = "N"
        case spelling = "C"
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
        bson[.nominal] = self.whom.nominal
        //  For roundtripping pre-0.9.9 BSON. After 1.0, we should encode it unconditionally.
        bson[.spelling] = self.whom.spelling.isEmpty ? nil : self.whom.spelling
    }
}
extension GenericConstraint:BSONDocumentDecodable, BSONDecodable
    where Scalar:BSONDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let (sigil, noun):(Sigil, String) = try bson[.generic].decode(
            as: BSON.UTF8View<ArraySlice<UInt8>>.self)
        {
            guard let sigil:Unicode.Scalar = $0.bytes.first.map(Unicode.Scalar.init(_:))
            else
            {
                throw SigilError.init()
            }
            guard let sigil:Sigil = .init(rawValue: sigil)
            else
            {
                throw SigilError.init(invalid: sigil)
            }

            return (sigil, .init(decoding: $0.bytes.dropFirst(), as: Unicode.UTF8.self))
        }

        let type:GenericType<Scalar> = .init(
            //  TODO: deoptionalize this after 1.0.
            spelling: try bson[.spelling]?.decode() ?? "",
            nominal: try bson[.nominal]?.decode())

        switch sigil
        {
        case .conformer:    self = .where(noun, is: .conformer, to: type)
        case .subclass:     self = .where(noun, is: .subclass, to: type)
        case .equal:        self = .where(noun, is: .equal, to: type)
        }
    }
}
