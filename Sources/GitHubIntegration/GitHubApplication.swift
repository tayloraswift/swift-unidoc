/// The essence of a GitHub application. Not to be confused with ``GitHubApp``.
public
protocol GitHubApplication:Equatable, Hashable, Sendable
{
    var client:String { get }
    var secret:String { get }
}
