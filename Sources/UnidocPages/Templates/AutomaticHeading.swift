import HTML

enum AutomaticHeading
{
    case packageTags

    case packageRepository
    case packageDependencies
    case platformRequirements
    case snapshotInformation
    case allModules

    case miscellaneous
    case otherModules
    case otherMembers

    case seeAlso

    case genericContext

    case allRequirements
    case restatesRequirements
    case implementsRequirements
    case overrides
    case superclasses
    case supertypes

    case interfaceBreakdown
    case documentationCoverage
}
extension AutomaticHeading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .packageTags:              "ss:package-tags"

        case .packageRepository:        "ss:package-repository"
        case .packageDependencies:      "ss:package-dependencies"
        case .platformRequirements:     "ss:platform-requirements"
        case .snapshotInformation:      "ss:snapshot-information"
        case .allModules:               "ss:all-modules"

        case .miscellaneous:            "ss:misc"
        case .otherModules:             "ss:other-modules"
        case .otherMembers:             "ss:other-members"

        case .seeAlso:                  "ss:see-also"

        case .genericContext:           "ss:generic-context"

        case .allRequirements:          "ss:requirements"
        case .restatesRequirements:     "ss:requirements-restated"
        case .implementsRequirements:   "ss:requirements-implemented"
        case .overrides:                "ss:overrides"
        case .superclasses:             "ss:superclasses"
        case .supertypes:               "ss:supertypes"

        case .interfaceBreakdown:       "ss:interface-breakdown"
        case .documentationCoverage:    "ss:documentation-coverage"
        }
    }
}
extension AutomaticHeading:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .packageTags:              "Package Tags"
        case .packageRepository:        "Package Repository"
        case .packageDependencies:      "Package Dependencies"
        case .platformRequirements:     "Platform Requirements"
        case .snapshotInformation:      "Snapshot Information"
        case .allModules:               "Modules"

        case .miscellaneous:            "Miscellaneous"
        case .otherModules:             "Other Modules"
        case .otherMembers:             "Other Members in Extension"

        case .seeAlso:                  "See Also"

        case .genericContext:           "Generic Context"

        case .allRequirements:          "Requirements"
        case .restatesRequirements:     "Restates"
        case .implementsRequirements:   "Implements"
        case .overrides:                "Overrides"
        case .superclasses:             "Superclasses"
        case .supertypes:               "Supertypes"

        case .interfaceBreakdown:       "Interface Breakdown"
        case .documentationCoverage:    "Documentation Coverage"
        }
    }
}
extension AutomaticHeading:HyperTextOutputStreamable
{
    static
    func += (hx:inout HTML.ContentEncoder, self:Self)
    {
        hx[.a] { $0.href = "#\(self.id)" } = "\(self)"
    }
}
