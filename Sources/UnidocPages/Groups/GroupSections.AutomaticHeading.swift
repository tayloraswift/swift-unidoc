import HTML

extension GroupSections
{
    enum AutomaticHeading
    {
        case allModules
        case otherModules

        case miscellaneous

        case allRequirements
        case restatesRequirements
        case implementsRequirements
        case overrides
        case superclasses
        case supertypes
    }
}
extension GroupSections.AutomaticHeading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .allModules:               "section:all-modules"
        case .otherModules:             "section:other-modules"

        case .miscellaneous:            "section:miscellaneous"

        case .allRequirements:          "section:all-requirements"
        case .restatesRequirements:     "section:restates-requirements"
        case .implementsRequirements:   "section:implements-requirements"
        case .overrides:                "section:overrides"
        case .superclasses:             "section:superclasses"
        case .supertypes:               "section:supertypes"
        }
    }
}
extension GroupSections.AutomaticHeading:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .allModules:               "Modules"
        case .otherModules:             "Other Modules"

        case .miscellaneous:            "Miscellaneous"

        case .allRequirements:          "Requirements"
        case .restatesRequirements:     "Restates"
        case .implementsRequirements:   "Implements"
        case .overrides:                "Overrides"
        case .superclasses:             "Superclasses"
        case .supertypes:               "Supertypes"
        }
    }
}
extension GroupSections.AutomaticHeading:HyperTextOutputStreamable
{
    static
    func += (hx:inout HTML.ContentEncoder, self:Self)
    {
        hx[.a] { $0.href = "#\(self.id)" } = "\(self)"
    }
}
