@frozen public
enum MultipartType:String, Equatable, Hashable, Sendable
{
    case formData = "form-data"
    case byteranges
}
extension MultipartType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
