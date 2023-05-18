@frozen public
struct ServerResource:Equatable, Sendable
{
    /// This URI is not necessarily the same as the canonical URI stored
    /// in this resource’s ``results``.
    public
    var location:String
    /// The kind of redirect this response returns, or its payload, if no
    /// redirect will be issued.
    public
    var response:Response
    /// The plurality of results returned by this response, or an error.
    /// A successful match does not mean this response includes a payload;
    /// it may return a redirect instead.
    public
    var results:Results

    @inlinable public
    init(location:String, response:Response, results:Results)
    {
        self.location = location
        self.response = response
        self.results = results
    }
}
extension ServerResource
{
    /// Returns the canonical location of this resource, if it has one, or
    /// its ``location`` otherwise.
    @inlinable public
    var canonical:String
    {
        self.results.canonical ?? self.location
    }
}
