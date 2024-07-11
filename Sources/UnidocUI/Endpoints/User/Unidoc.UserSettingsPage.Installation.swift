import HTML

extension Unidoc.UserSettingsPage
{
    struct Installation
    {
        let organization:String?
        let id:Int32?

        init(organization:String?, id:Int32?)
        {
            self.organization = organization
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
                $0.href = self.organization.map
                {
                    "https://github.com/organizations/\($0)/settings/installations/\(id)"
                } ?? "https://github.com/settings/installations/\(id)"

                $0.rel = .external
            } = "installation settings"
        }
        else
        {
            div[.span] { $0.class = "placeholder" } = "no installation"
        }
    }
}
