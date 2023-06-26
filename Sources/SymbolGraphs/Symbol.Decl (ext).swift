import BSONDecoding
import BSONEncoding
import Symbols

/// Uses the ``RawRepresentable`` conformance, which encodes without
/// the interior colon.
extension Symbol.Decl:BSONDecodable, BSONEncodable
{
}
