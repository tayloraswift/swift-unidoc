import HTML
import Media
import URI

extension Unidoc
{
    struct BuildRequestPage
    {
        let action:URI

        init(action:URI)
        {
            self.action = action
        }
    }
}
extension Unidoc.BuildRequestPage
{

}
extension Unidoc.BuildRequestPage:Unidoc.ConfirmationPage
{
    var button:String { "Build package" }
    var title:String { "Build package?" }

    func form(_ form:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        form[.p] = """
        A builder will select a recent version of the package once one becomes available.
        """
        form[.p] = """
        If you tag a new release in the meantime, it might build that instead.
        """
    }
}
