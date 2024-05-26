/// Enumerates supported HTTP versions. This type also serves as a namespace for other
/// HTTP-related types.
@frozen public
enum HTTP:Comparable
{
    case http1_1
    case http2
}
