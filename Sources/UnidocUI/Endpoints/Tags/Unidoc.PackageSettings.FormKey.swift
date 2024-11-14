extension Unidoc.PackageSettings
{
    enum FormKey:String, CaseIterable, Sendable
    {
        case theme = "theme"
    }
}
extension Unidoc.PackageSettings.FormKey:CustomStringConvertible
{
    var description:String { self.rawValue }
}
extension Unidoc.PackageSettings.FormKey:LosslessStringConvertible
{
    init?(_ description:String) { self.init(rawValue: description) }
}
