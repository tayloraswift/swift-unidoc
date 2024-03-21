import MongoQL
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct UserSession:Equatable, Hashable, Sendable
    {
        public
        let account:Account
        public
        let cookie:Int64

        @inlinable
        init(account:Account, cookie:Int64)
        {
            self.account = account
            self.cookie = cookie
        }
    }
}
extension Unidoc.UserSession:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.account)_\(UInt64.init(bitPattern: self.cookie))" }
}
extension Unidoc.UserSession:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        if  let colon:String.Index = description.firstIndex(of: "_"),
            let account:Unidoc.Account = .init(description[..<colon]),
            let cookie:UInt64 = .init(description[description.index(after: colon)...])
        {
            self.init(account: account, cookie: .init(bitPattern: cookie))
        }
        else
        {
            return nil
        }
    }
}
