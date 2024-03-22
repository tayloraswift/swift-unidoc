extension Unidoc
{
    @frozen public
    enum BuildOutcome:Equatable, Sendable
    {
        case failure(Failure)
    }
}
