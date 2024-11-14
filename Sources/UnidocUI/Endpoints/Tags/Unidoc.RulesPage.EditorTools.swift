import HTML
import Media

extension Unidoc.RulesPage
{
    enum EditorTools
    {
        case editor(Unidoc.Package?, Unidoc.Account)
        case member
        case owner
    }
}
extension Unidoc.RulesPage.EditorTools:HTML.OutputStreamable
{
    static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        switch self
        {
        case .editor(let package?, let account):
            div[.span] = "Editor"
            div[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Unidoc.Post[.packageRules])"
                $0.method = "post"
            }
                content:
            {
                $0[.input]
                {
                    $0.type = "hidden"
                    $0.name = "package"
                    $0.value = "\(package)"
                }

                $0[.input]
                {
                    $0.type = "hidden"
                    $0.name = "revoke"
                    $0.value = "\(account)"
                }

                $0[.button]
                {
                    $0.class = "text"
                    $0.type = "submit"
                } = "Revoke"
            }

        case .editor(nil, _):
            div[.span] = "Editor"

        case .member:
            div[.span] = "Member"

        case .owner:
            div[.span] = "Owner"
        }
    }
}
