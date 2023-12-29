import HTML
import Signatures
import Unidoc

struct ExtensionHeading
{
    let context:IdentifiablePageContext<Unidoc.Scalar>

    private
    let display:String
    private
    let culture:Unidoc.Scalar
    private
    let `where`:[GenericConstraint<Unidoc.Scalar?>]

    init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
        display:String,
        culture:Unidoc.Scalar,
        where:[GenericConstraint<Unidoc.Scalar?>])
    {
        self.context = context
        self.display = display
        self.culture = culture
        self.where = `where`
    }
}
extension ExtensionHeading:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h2]
        {
            $0 += self.display
            $0 ?= self.context.link(module: self.culture)
        }

        html[.code] { $0.class = "constraints" } = self.context.constraints(self.where)
    }
}
