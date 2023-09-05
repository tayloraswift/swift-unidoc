import BSONDecoding
import BSONEncoding

extension Account
{
    @frozen public
    enum ID:Equatable, Hashable, Sendable
    {
        case machine(Int32)
        case github(Int32)
    }
}
extension Account.ID:RawRepresentable
{
    @inlinable public
    init?(rawValue:Int64)
    {
        let scalar:Int32 = .init(truncatingIfNeeded: rawValue)

        switch Namespace.init(rawValue: rawValue >> 32)
        {
        case .machine?: self = .machine(scalar)
        case .github?:  self = .github(scalar)
        case nil:       return nil
        }
    }

    @inlinable public
    var rawValue:Int64
    {
        switch self
        {
        case .machine(let scalar): return Namespace.machine[scalar]
        case .github(let scalar):  return Namespace.github[scalar]
        }
    }
}
extension Account.ID:BSONDecodable, BSONEncodable
{
}
