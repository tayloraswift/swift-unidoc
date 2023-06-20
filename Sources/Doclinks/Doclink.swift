import URI

@frozen public
struct Doclink:Equatable, Hashable, Sendable
{
    public
    let absolute:Bool
    public
    let path:[String]

    @inlinable public
    init(absolute:Bool, path:[String])
    {
        self.absolute = absolute
        self.path = path
    }
}
extension Doclink
{
    @inlinable public
    var bundle:String?
    {
        self.absolute ? self.path.first : nil
    }
}
extension Doclink:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "doc:\(self.absolute ? "//" : "")\(self.path.joined(separator: "/"))"
    }
}
extension Doclink:LosslessStringConvertible
{
    public
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
}
extension Doclink
{
    public
    init?(doc uri:Substring)
    {
        //  Count and trim the leading slashes. One leading slash is meaningless,
        //  two or more indicates a “bundle” root.
        var start:String.Index = uri.startIndex
        var slashes:Int = 0
        while start < uri.endIndex, uri[start] == "/"
        {
            if  slashes < 2
            {
                slashes += 1
                start = uri.index(after: start)
            }
            else
            {
                return nil
            }
        }
        if  let path:URI.Path = .init(relative: uri[start...])
        {
            self.init(absolute: slashes >= 2, path: path.normalized())
        }
        else
        {
            return nil
        }
    }
}
