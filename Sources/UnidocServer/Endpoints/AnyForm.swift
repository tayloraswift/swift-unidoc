import Multiparts

enum AnyForm
{
    case urlencoded([String: String])
    case multipart(MultipartForm)
}
