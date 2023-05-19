public
enum MultipartSplitError:Error, Equatable, Sendable
{
    case invalidPreamble
    case invalidBoundary
}
