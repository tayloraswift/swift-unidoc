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
        A builder will select a recent version of the package once one becomes available. \
        If you tag a new release in the meantime, it might build that instead.
        """

        form[.p]
        {
            $0[.label]
            {
                $0.class = "checkbox"
                $0.title = "Build the package even if it already has a symbol graph."
            }
                content:
            {
                $0[.input]
                {
                    $0.type = "checkbox"
                    $0.name = "force"
                    $0.value = "true"
                }

                $0[.span] = "Force rebuild of existing documentation"
            }
        }
        form[.p]
        {
            $0[.label]
            {
                $0.class = "checkbox"
                $0.title = "Build the latest prerelease instead of the latest release."
            }
                content:
            {
                $0[.input]
                {
                    $0.type = "checkbox"
                    $0.name = "series"
                    $0.value = "prerelease"
                }

                $0[.span] = "Build prereleases"
            }
        }
    }
}
