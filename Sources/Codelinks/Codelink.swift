@frozen public
struct CodelinkV4:Equatable, Hashable, Sendable
{
    public
    let base:Bool
    public
    let path:Path
    public
    let suffix:Suffix?
}
