import BSON

extension Unidoc.BuildOutcome
{
    @frozen public
    enum FailureReason:Int32, Equatable, Sendable
    {
        case timeout = 0
    }
}
extension Unidoc.BuildOutcome.FailureReason:BSONDecodable, BSONEncodable
{
}
