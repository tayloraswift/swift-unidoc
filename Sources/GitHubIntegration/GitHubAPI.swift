@frozen public
struct GitHubAPI
{
    public
    let agent:String

    @inlinable public
    init(agent:String)
    {
        self.agent = agent
    }
}
