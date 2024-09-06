import HTML
import Media
import Symbols
import URI

extension Unidoc
{
    struct BuildTools
    {
        let prerelease:BuildFormTool
        let release:BuildFormTool
        let running:[Unidoc.PendingBuild]
        let view:Unidoc.Permissions
        let back:URI
    }
}
extension Unidoc.BuildTools:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.div]
        {
            for shortcut:Unidoc.BuildFormTool in [self.prerelease, self.release]
            {
                $0[.form]
                {
                    $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                    $0.action = "\(Unidoc.Post[.build, confirm: true])"
                    $0.method = "post"
                } = shortcut
            }
        }

        section[.ol]
        {
            for build:Unidoc.PendingBuild in self.running
            {
                let tooltip:String
                let label:String

                switch build.stage
                {
                case nil:
                    tooltip = "The build has not yet started."
                    label = "Queued"

                case .initializing?:
                    tooltip = "The builder is initializing."
                    label = "Git"

                case .cloningRepository?:
                    tooltip = "The builder is cloning the package’s repository."
                    label = "Git"

                case .resolvingDependencies?:
                    tooltip = "The builder is resolving the package’s dependencies."
                    label = "SwiftPM"

                case .compilingCode?:
                    tooltip = "The builder is compiling the package’s source code."
                    label = "Swift"
                }

                $0[.li]
                {
                    $0[.form]
                    {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(Unidoc.Post[.build, confirm: true])"
                        $0.method = "post"
                    } = Unidoc.BuildFormTool.control(pending: build, view: self.view)

                    $0[.div]
                    {
                        $0.class = build.stage == nil ? "phase queued" : "phase started"
                        $0.title = tooltip
                    } = label

                    $0[.div]
                    {
                        $0.class = "ref"
                    } = build.name.ref
                }
            }
        }
    }
}
