@frozen public
enum MultipartType:Equatable, Hashable, Sendable
{
    case byteranges (boundary:String?)
    case form_data  (boundary:String?)
}
extension MultipartType
{
    @inlinable public static
    var byteranges:MultipartType { .byteranges(boundary: nil) }

    @inlinable public static
    var form_data:MultipartType { .form_data(boundary: nil) }
}
extension MultipartType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .byteranges(boundary: let boundary?):
            "multipart/byteranges; boundary=\(boundary)"

        case .byteranges(boundary: nil):
            "multipart/byteranges"

        case .form_data(boundary: let boundary?):
            "multipart/form-data; boundary=\(boundary)"

        case .form_data(boundary: nil):
            "multipart/form-data"
        }
    }
}
