import HTTP
import MongoDB
import UnidocDB
import UnidocRecords

extension Unidoc {
    public protocol MeteredOperation: RestrictedOperation {
        var account: Unidoc.Account { get }
        var rights: Unidoc.UserRights { get set }
    }
}
extension Unidoc.MeteredOperation {
    /// Everyone can use this endpoint, as long as they are authenticated.
    @inlinable public mutating func admit(user: Unidoc.UserRights) -> Bool {
        self.rights = user
        return true
    }
}
extension Unidoc.MeteredOperation {
    /// A convenience method for charging the currently-authenticated user’s account.
    /// Administratrices will always be charged a `cost` of 1, regardless of the actual value
    /// specified.
    ///
    /// This method isn’t smart enough to skip the query if `cost` is zero; it is the
    /// responsibility of the caller to check this if it is using a dynamic cost formula.
    ///
    /// This isn’t called automatically, to allow for maximum customization.
    func charge(cost: Int, in db: Unidoc.DB) async throws -> Unidoc.PolicyErrorPage? {
        //  The cost for administratrices is not *zero*, mainly so that it’s easier for us to
        //  tell if the rate limiting system is working.
        if  let _: Int = try await db.users.charge(
                apiKey: nil,
                user: self.account,
                cost: self.rights.level == .administratrix ? 1 : 8
            ) {
            return nil
        } else {
            return .init(
                illustration: .error4xx_jpg,
                heading: "Inactive or nonexistent API key",
                message: """
                The key may have been changed, or it may have exceeded its hourly rate limit.
                """,
                status: 429
            )
        }
    }
}
