import HTML

extension Unidoc
{
    struct UserCard
    {
        let id:Account
        let symbol:String?
        let icon:String?

        init(id:Account, symbol:String?, icon:String?)
        {
            self.id = id
            self.symbol = symbol
            self.icon = icon
        }
    }
}
extension Unidoc.UserCard:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.header]
        {
            if  let icon:String = self.icon
            {
                $0[.img] { $0.class = "icon" ; $0.src = icon }
            }
            else
            {
                $0[.div] { $0.class = "icon" }
            }

            $0[.a]
            {
                $0.href = "\(Unidoc.UserPropertyEndpoint[self.id])"
            } = self.symbol ?? "(automated user)"
        }
    }
}
