import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Unidoc
{
    public
    protocol MeteredOperation:RestrictedOperation
    {
        var privileges:Unidoc.User.Level { get set }
        var account:Unidoc.Account { get }
    }
}
extension Unidoc.MeteredOperation
{
    /// Everyone can use this endpoint, as long as they are authenticated.
    @inlinable public mutating
    func admit(level:Unidoc.User.Level) -> Bool
    {
        self.privileges = level
        return true
    }
}
extension Unidoc.MeteredOperation
{
    /// A convenience method for charging the currently-authenticated user’s account.
    /// Administratrices will always be charged a `cost` of 1, regardless of the actual value
    /// specified.
    ///
    /// This method isn’t smart enough to skip the query if `cost` is zero; it is the
    /// responsibility of the caller to check this if it is using a dynamic cost formula.
    ///
    /// This isn’t called automatically, to allow for maximum customization.
    func charge(cost:Int,
        from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        //  The cost for administratrices is not *zero*, mainly so that it’s easier for us to
        //  tell if the rate limiting system is working.
        if  let _:Int = try await server.db.users.charge(apiKey: nil,
                user: self.account,
                cost: self.privileges == .administratrix ? 1 : 8,
                with: session)
        {
            return nil
        }
        else
        {
            let display:Unidoc.PolicyErrorPage = .init(illustration: .error4xx_jpg,
                message: "Inactive or nonexistent API key",
                status: 429)
            return display.response(format: server.format)
        }
    }
}
