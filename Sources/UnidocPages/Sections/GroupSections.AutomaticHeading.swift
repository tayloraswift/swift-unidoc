import HTML

extension GroupSections
{
    enum AutomaticHeading
    {
        case allModules
        case otherModules

        case miscellaneous
        case seeAlso

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
        case .allModules:               "ss:all-modules"
        case .otherModules:             "ss:other-modules"

        case .miscellaneous:            "ss:misc"
        case .seeAlso:                  "ss:see-also"

        case .allRequirements:          "ss:requirements"
        case .restatesRequirements:     "ss:requirements-restated"
        case .implementsRequirements:   "ss:requirements-implemented"
        case .overrides:                "ss:overrides"
        case .superclasses:             "ss:superclasses"
        case .supertypes:               "ss:supertypes"

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
        case .seeAlso:                  "See Also"

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
