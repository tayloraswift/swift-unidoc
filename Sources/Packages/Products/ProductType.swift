@frozen public
enum ProductType:Hashable, Equatable, Sendable
{
    case executable
    case library(LibraryMode)
    case macro
    case plugin
    case snippet
    case test
}
