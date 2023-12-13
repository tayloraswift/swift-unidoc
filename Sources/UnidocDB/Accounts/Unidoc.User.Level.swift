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
    }
}
extension Unidoc.User.Level:BSONDecodable, BSONEncodable
{
}
