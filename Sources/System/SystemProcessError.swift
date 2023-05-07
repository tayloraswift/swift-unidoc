public
enum SystemProcessError:Error, Equatable, Sendable
{
    case launch(Int32, Operation)
    case exit(Int32)
}
