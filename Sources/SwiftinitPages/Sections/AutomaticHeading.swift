import HTML

enum AutomaticHeading:Equatable, Comparable
{
    case packageTags

    case packageRepository
    case packageDependencies
    case platformRequirements
    case snapshotInformation
    case allModules
    case allProducts
    case allProductConstituents

    case miscellaneous
    case otherModules
    case otherMembers
    case otherProducts

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
        case .allProducts:              "ss:all-products"
        case .allProductConstituents:   "ss:all-product-constituents"

        case .miscellaneous:            "ss:misc"
        case .otherMembers:             "ss:other-members"
        case .otherModules:             "ss:other-modules"
        case .otherProducts:            "ss:other-products"

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
        case .allProducts:              "Products"
        case .allProductConstituents:   "Product Constituents"

        case .miscellaneous:            "Miscellaneous"
        case .otherMembers:             "Other Members in Extension"
        case .otherModules:             "Other Modules"
        case .otherProducts:            "Other Products"

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
extension AutomaticHeading
{
    func window<T>(_ section:inout HTML.ContentEncoder,
        listing items:[T],
        limit:Int,
        open:Bool = false,
        with yield:(inout HTML.ContentEncoder, T) -> ())
    {
        section[.h2] { $0.id = self.id } = self

        guard limit < items.count
        else
        {
            return section[.ul]
            {
                for item:T in items
                {
                    yield(&$0, item)
                }
            }
        }

        section[.details, { $0.open = open }]
        {
            $0[.summary]
            {
                $0[.p] { $0.class = "view" } = "View members"

                $0[.p] { $0.class = "hide" } = "Hide members"

                $0[.p, { $0.class = "reason" }]
                {
                    $0 += """
                    This section is hidden by default because it contains too many \

                    """

                    $0[.span] { $0.class = "count" } = "(\(items.count))"

                    $0 += """
                        members.
                    """
                }
            }
            $0[.ul]
            {
                for item:T in items
                {
                    yield(&$0, item)
                }
            }
        }
    }
}
