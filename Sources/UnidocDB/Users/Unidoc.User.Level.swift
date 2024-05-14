import BSON
import UnidocRecords

extension Unidoc.User
{
    @frozen public
    enum Level:Int32, Equatable, Hashable, Sendable
    {
        /// A site administratrix.
        case administratrix = 0
        /// A machine user.
        case machine = 1
        /// A human user.
        case human = 2
        /// The lowest level of access, which is used for non-playable entities like
        /// organizations.
        case guest = 256
    }
}
extension Unidoc.User.Level:BSONDecodable, BSONEncodable
{
}
