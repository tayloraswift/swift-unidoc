import HTML

extension Unidoc
{
    @frozen public
    struct ApplicationCornice
    {
        @usableFromInline
        let username:String?
        @usableFromInline
        let official:Bool

        @inlinable
        init(username:String?, official:Bool)
        {
            self.username = username
            self.official = official
        }
    }
}
extension Unidoc.ApplicationCornice:HTML.OutputStreamable
{
    @inlinable public static
    func += (nav:inout HTML.ContentEncoder, self:Self)
    {
        nav[.div]
        {
            $0[.a] { $0.href = "/" } = self.official ? "swiftinit" : "preview"
        }
        nav[.div]
        {
            if  let username:String = self.username
            {
                $0[.a] { $0.href = "\(Unidoc.ServerRoot.account)" } = username
            }
            else
            {
                $0[.a] { $0.href = "\(Unidoc.ServerRoot.login)" } = "login"
            }
        }
    }
}
