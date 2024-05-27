import UnidocRecords

extension Unidoc.UserSession
{
    @frozen public
    struct Web:Equatable, Hashable, Sendable
    {
        public
        let id:Unidoc.Account
        public
        let cookie:Int64

        @inlinable public
        init(id:Unidoc.Account, cookie:Int64)
        {
            self.id = id
            self.cookie = cookie
        }
    }
}
extension Unidoc.UserSession.Web:CustomStringConvertible
{
    /// For historical reasons, the ``cookie`` is rendered in base 10 instead of base 16.
    @inlinable public
    var description:String { "\(self.id)_\(UInt64.init(bitPattern: self.cookie))" }
}
extension Unidoc.UserSession.Web:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:some StringProtocol)
    {
        guard
        let separator:String.Index = string.firstIndex(of: "_"),
        let id:Unidoc.Account = .init(string[..<separator]),
        let cookie:UInt64 = .init(string[string.index(after: separator)...])
        else
        {
            return nil
        }

        self.init(id: id, cookie: .init(bitPattern: cookie))
    }
}
