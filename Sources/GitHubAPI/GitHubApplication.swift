/// The essence of a GitHub application. Not to be confused with ``GitHubApp``.
public
protocol GitHubApplication<Credentials>:Equatable, Hashable, Sendable
{
    associatedtype Credentials

    var client:String { get }
    var secret:String { get }
}
