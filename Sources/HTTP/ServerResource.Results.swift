extension ServerResource
{
    /// The plurality of results returned by the relevant response, or an error.
    @frozen public
    enum Results:Equatable, Hashable, Sendable
    {
        case error

        case forbidden

        case many
        case none
        case one(canonical:String?)
    }
}
extension ServerResource.Results
{
    @inlinable public
    var canonical:String?
    {
        switch self
        {
        case .error, .forbidden, .many, .none:  return nil
        case .one(canonical: let canonical):    return canonical
        }
    }
}
