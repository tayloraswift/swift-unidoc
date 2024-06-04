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

        @inlinable public
        init(username:String? = nil, official:Bool = true)
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
            $0[.a] { $0.href = "\(Unidoc.ServerRoot.account)" } = self.username
        }
    }
}
