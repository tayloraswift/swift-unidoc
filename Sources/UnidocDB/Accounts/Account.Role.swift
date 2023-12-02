import BSON

extension Account
{
    @frozen public
    enum Role:Int32, Equatable, Hashable, Sendable
    {
        /// A site administrator.
        case administrator = 0
        /// A machine user.
        case machine = 1
        /// A human user.
        case human = 2
    }
}
extension Account.Role:BSONDecodable, BSONEncodable
{
}
