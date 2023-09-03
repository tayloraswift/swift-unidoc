@frozen public
struct GitHubToken:Equatable, Hashable, Sendable
{
    public
    let value:String
    public
    let secondsRemaining:Int64

    @inlinable public
    init(value:String, secondsRemaining:Int64)
    {
        self.value = value
        self.secondsRemaining = secondsRemaining
    }
}
