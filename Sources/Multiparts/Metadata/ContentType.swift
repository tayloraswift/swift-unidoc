import Media

@frozen public
enum ContentType
{
    case multipart(MultipartType)
    case media(MediaType)
}
extension ContentType
{
    @inlinable public
    var multipart:MultipartType?
    {
        switch self
        {
        case .multipart(let type):  return type
        case .media:                return nil
        }
    }
    @inlinable public
    var media:MediaType?
    {
        switch self
        {
        case .multipart:            return nil
        case .media(let type):      return type
        }
    }
}
extension ContentType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .multipart(let type):  return type.description
        case .media(let type):      return type.description
        }
    }
}
extension ContentType:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:String)
    {
        self.init(string[...])
    }
    public
    init?(_ string:Substring)
    {
        if  let value:Self = try? ContentTypeRule<String.Index>.parse(string.utf8)
        {
            self = value
        }
        else
        {
            return nil
        }
    }
}
