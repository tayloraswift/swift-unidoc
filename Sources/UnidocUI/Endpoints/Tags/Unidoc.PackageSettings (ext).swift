import UnidocRecords

extension Unidoc.PackageSettings
{
    public
    init?(parameters form:borrowing [String: String])
    {
        guard
        let theme:String = form["\(FormKey.theme)"]
        else
        {
            return nil
        }

        self.init(theme: theme)
    }
}
