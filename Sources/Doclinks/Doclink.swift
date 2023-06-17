@frozen public
struct Doclink
{
    public
    let bundle:String
    public
    let path:[String]
}
extension Doclink
{
    @inlinable public
    init?(_ description:String)
    {
        if  let start:String.Index = description.index(description.startIndex,
                offsetBy: 4,
                limitedBy: description.endIndex),
            description[..<start] == "doc:"
        {
            self.init(doc: description[start...])
        }
        else
        {
            return nil
        }
    }

    public
    init?(doc uri:Substring)
    {
        let path:[Substring] = uri.split(separator: "/", omittingEmptySubsequences: false)
        if  path.count > 2,
            path[..<2] == ["", ""]
        {

        }
        else
        {

        }

        fatalError("unimplemented")
    }
}
