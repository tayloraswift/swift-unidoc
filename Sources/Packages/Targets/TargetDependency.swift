@frozen public
enum TargetDependency:Equatable, Sendable
{
    case product(Product)
    case target(Target)
}
