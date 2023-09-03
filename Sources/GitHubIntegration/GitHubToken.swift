@frozen public
struct GitHubToken:Equatable, Hashable, Sendable
{
    public
    let secondsRemaining:Int
    public
    let value:String

    @inlinable public
    init(value:String, secondsRemaining:Int)
    {
        self.value = value
        self.secondsRemaining = secondsRemaining
    }
}
