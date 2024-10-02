import HTML
import SemanticVersions
import Symbols
import UnidocDB

extension Unidoc
{
    struct BuildTemplateTool
    {
        let form:BuildTemplate
        let view:Permissions
    }
}
extension Unidoc.BuildTemplateTool:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        form[.dl]
        {
            $0[.dt] = "Platform preference"
            $0[.dd]
            {
                $0[.select]
                {
                    $0.name = Unidoc.BuildTemplate.Parameter.platform
                    $0.required = true
                    $0.disabled = !self.view.editor
                }
                    content:
                {
                    if  let triple:Symbol.Triple = self.form.platform
                    {
                        $0[.option]
                        {
                            $0.selected = true
                            $0.value = "\(triple)"
                        } = "\(triple)"
                    }

                    $0[.option]
                    {
                        $0.selected = self.form.platform == nil
                        $0.value = ""
                    } = "Default"

                    for option:Symbol.Triple in [
                        .aarch64_unknown_linux_gnu,
                        .arm64_apple_macosx15_0,
                    ]
                    {
                        if  case option? = self.form.platform
                        {
                            continue
                        }

                        $0[.option] { $0.value = "\(option)" } = "\(option)"
                    }
                }
            }

            $0[.dt] = "Swift compiler"
            $0[.dd]
            {
                $0[.select]
                {
                    $0.name = Unidoc.BuildTemplate.Parameter.toolchain
                    $0.required = true
                    $0.disabled = !self.view.editor
                }
                    content:
                {
                    let current:String?
                    if  let toolchain:PatchVersion = self.form.toolchain
                    {
                        current = "\(toolchain)"
                        $0[.option] { $0.selected = true ; $0.value = current } = current
                    }
                    else
                    {
                        current = nil
                    }

                    $0[.option]
                    {
                        $0.selected = self.form.toolchain == nil ; $0.value = ""
                    } = "Default"

                    for option:String in [
                        "6.0.1",
                    ]
                    {
                        if  case option? = current
                        {
                            continue
                        }

                        $0[.option] { $0.value = option } = option
                    }
                }
            }
        }

        form[.button]
        {
            $0.class = "area"
            $0.type = "submit"

            if !self.view.authenticated
            {
                $0.disabled = true
                $0.title = "You are not logged in!"
            }
            else if !self.view.editor
            {
                $0.disabled = true
                $0.title = "You are not an editor for this package!"
            }
        } = "Update configuration"
    }
}
