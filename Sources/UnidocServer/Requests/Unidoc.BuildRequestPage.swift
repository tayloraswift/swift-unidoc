import HTML
import Media
import URI

extension Unidoc
{
    struct BuildRequestPage
    {
        let selector:Unidoc.VolumeSelector
        let cancel:Bool
        let action:URI

        init(selector:Unidoc.VolumeSelector, cancel:Bool, action:URI)
        {
            self.selector = selector
            self.cancel = cancel
            self.action = action
        }
    }
}
extension Unidoc.BuildRequestPage:Unidoc.ConfirmationPage
{
    var button:String { self.cancel ? "Cancel build" : "Build package" }
    var title:String { self.cancel ? "Cancel build?" : "Build package?" }

    func form(_ form:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        form[.p]
        {
            let package:URI = Unidoc.TagsEndpoint[self.selector.package]
            if  self.cancel
            {
                $0 += "You can cancel the build for "
                $0[.a] { $0.href = "\(package)" } = "\(self.selector.package)"
                $0 += " if it has not started yet."
            }
            else if
                let version:Substring = self.selector.version
            {
                $0 += "A builder will build the package"
                $0[.a] { $0.href = "\(package)" } = "\(self.selector.package)"
                $0 += " at "
                $0[.code] = "\(version)"
                $0 += """
                 once one becomes available. If you move the ref in the meantime, it might \
                build the new commit instead.
                """
            }
            else
            {
                $0 += "A builder will select a recent version of the package "
                $0[.a] { $0.href = "\(package)" } = "\(self.selector.package)"
                $0 += """
                 once one becomes available. If you tag a new release in the meantime, \
                it might build that instead.
                """
            }
        }

        form[.p]
        {
            $0[.label]
            {
                $0.class = "checkbox"
                $0.title = "Build the selected version even if it already has a symbol graph."
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

        if  self.cancel
        {
            return
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
