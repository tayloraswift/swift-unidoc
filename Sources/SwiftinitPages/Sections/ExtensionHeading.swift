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
    let constraints:[GenericConstraint<Unidoc.Scalar?>]

    init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
        display:String,
        culture:Unidoc.Scalar,
        where constraints:[GenericConstraint<Unidoc.Scalar?>])
    {
        self.context = context
        self.display = display
        self.culture = culture
        self.constraints = constraints
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

        html[.code] { $0.class = "constraints" } = self.context.constraints(self.constraints)
    }
}
