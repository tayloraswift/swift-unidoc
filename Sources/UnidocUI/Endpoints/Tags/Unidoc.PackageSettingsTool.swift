import HTML

extension Unidoc
{
    struct PackageSettingsTool
    {
        let settings:PackageSettings
        let view:Permissions
    }
}
extension Unidoc.PackageSettingsTool:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        form[.dl]
        {
            $0[.dt] = "Theme"
            $0[.dd]
            {
                $0[.select]
                {
                    $0.name = "\(Unidoc.PackageSettings.FormKey.theme)"
                    $0.disabled = !self.view.editor
                }
                    content:
                {
                    $0[.option]
                    {
                        $0.selected = self.settings.theme == nil
                        $0.value = ""
                    } = "Default"

                    for option:String in ["bast", "eden"]
                    {
                        $0[.option]
                        {
                            $0.selected = self.settings.theme == option
                            $0.value = option
                        } = option
                    }
                }
            }
        }

        form[.button]
        {
            $0.class = "region"
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
        } = "Update settings"
    }
}
