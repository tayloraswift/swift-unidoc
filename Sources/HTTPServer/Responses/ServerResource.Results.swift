extension ServerResource
{
    @frozen public
    enum Results:Equatable, Hashable, Sendable
    {
        case error
        case many
        case none
        case one(canonical:String)
    }
}
extension ServerResource.Results
{
    @inlinable public
    var canonical:String?
    {
        switch self
        {
        case .error, .many, .none:              return nil
        case .one(canonical: let canonical):    return canonical
        }
    }
}
