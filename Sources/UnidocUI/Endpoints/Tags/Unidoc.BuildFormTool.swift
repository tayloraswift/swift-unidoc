import HTML
import Symbols
import UnidocRecords

extension Unidoc
{
    struct BuildFormTool
    {
        let form:BuildForm
        let area:Bool
        let disabled:Inhibitor?

        init(form:BuildForm, area:Bool, disabled:Inhibitor? = nil)
        {
            self.form = form
            self.area = area
            self.disabled = disabled
        }
    }
}
extension Unidoc.BuildFormTool
{
    static
    func shortcut(buildable:String?,
        submitted:Bool,
        package:Symbol.Package,
        view:Unidoc.Permissions) -> Self
    {
        guard
        let buildable:String
        else
        {
            //  Use the empty string for the ref, as the form should not be submittable at all.
            return .init(form: .init(
                    symbol: .init(package: package, ref: ""),
                    action: .submit),
                area: true,
                disabled: .unavailable)
        }

        let form:Unidoc.BuildForm = .init(
            symbol: .init(package: package, ref: buildable),
            action: .submit)

        if  submitted
        {
            return .init(form: form, area: true, disabled: .alreadySubmitted)
        }

        guard case _? = view.global
        else
        {
            return .init(form: form, area: true, disabled: .unauthenticated)
        }

        guard view.editor
        else
        {
            return .init(form: form, area: true, disabled: .unauthorized)
        }

        return .init(form: form, area: true)
    }

    static
    func control(pending build:Unidoc.PendingBuild, view:Unidoc.Permissions) -> Self
    {
        let form:Unidoc.BuildForm = .init(symbol: build.name, action: .cancel)

        guard case nil = build.launched
        else
        {
            return .init(form: form, area: true, disabled: .alreadyStarted)
        }

        guard case _? = view.global
        else
        {
            return .init(form: form, area: true, disabled: .unauthenticated)
        }

        guard view.editor
        else
        {
            return .init(form: form, area: true, disabled: .unauthorized)
        }

        return .init(form: form, area: true)
    }
}
extension Unidoc.BuildFormTool:HTML.OutputStreamable
{
    static
    func += (form:inout HTML.ContentEncoder, self:Self)
    {
        form[.input]
        {
            $0.type = "hidden"
            $0.name = Unidoc.BuildForm.symbol
            $0.value = "\(self.form.symbol)"
        }

        form[.input]
        {
            $0.type = "hidden"
            $0.name = Unidoc.BuildForm.action
            $0.value = "\(self.form.action)"
        }

        let label:String

        switch self.form.action
        {
        case .submit:   label = "Request build"
        case .cancel:   label = "Cancel build"
        }

        form[.button]
        {
            $0.class = self.area ? "area" : "text"
            $0.type = "submit"

            guard
            let inhibitor:Inhibitor = self.disabled
            else
            {
                return
            }

            $0.disabled = true

            switch inhibitor
            {
            case .alreadyStarted:   $0.title = "This build has already started!"
            case .alreadySubmitted: $0.title = "This build has already been queued!"
            case .unauthenticated:  $0.title = "You are not logged in!"
            case .unauthorized:     $0.title = "You are not an editor of this package!"
            case .unavailable:      $0.title = "This repository does not have such a tag yet!"
            }
        } = label
    }
}
