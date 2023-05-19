@frozen public
enum MultipartType:Equatable, Hashable, Sendable
{
    case byteranges (boundary:String)
    case formData   (boundary:String)
}
extension MultipartType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .byteranges(boundary: let boundary):
            return "multipart/byteranges; boundary=\(boundary)"
        case .formData(boundary: let boundary):
            return "multipart/form-data; boundary=\(boundary)"
        }
    }
}
