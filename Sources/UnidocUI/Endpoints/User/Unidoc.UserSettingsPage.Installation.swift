import HTML

extension Unidoc.UserSettingsPage
{
    struct Installation
    {
        let id:Int32?

        init(id:Int32?)
        {
            self.id = id
        }
    }
}
extension Unidoc.UserSettingsPage.Installation:HTML.OutputStreamable
{
    static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        if  let id:Int32 = self.id
        {
            div[.a]
            {
                $0.target = "_blank"
                $0.href = "https://github.com/settings/installations/\(id)"
                $0.rel = .external
            } = "installation settings"
        }
        else
        {
            div[.span] { $0.class = "placeholder" } = "no installation"
        }
    }
}
