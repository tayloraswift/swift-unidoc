import HTML

enum AutomaticHeading:Equatable, Comparable
{
    case allModules
    case allProducts
    case allProductConstituents

    case miscellaneous
    case otherCases
    case otherModules
    case otherMembers
    case otherProducts
    case otherRequirements

    case seeAlso

    case allCases
    case allRequirements
    case restatesRequirements
    case implementsRequirements
    case overrides
    case superclasses
    case supertypes
}
extension AutomaticHeading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .allModules:               "ss:all-modules"
        case .allProducts:              "ss:all-products"
        case .allProductConstituents:   "ss:all-product-constituents"

        case .miscellaneous:            "ss:misc"
        case .otherCases:               "ss:other-cases"
        case .otherMembers:             "ss:other-members"
        case .otherModules:             "ss:other-modules"
        case .otherProducts:            "ss:other-products"
        case .otherRequirements:        "ss:other-requirements"

        case .seeAlso:                  "ss:see-also"

        case .allCases:                 "ss:cases"
        case .allRequirements:          "ss:requirements"
        case .restatesRequirements:     "ss:requirements-restated"
        case .implementsRequirements:   "ss:requirements-implemented"
        case .overrides:                "ss:overrides"
        case .superclasses:             "ss:superclasses"
        case .supertypes:               "ss:supertypes"
        }
    }
}
extension AutomaticHeading:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .allModules:               "Modules"
        case .allProducts:              "Products"
        case .allProductConstituents:   "Product constituents"

        case .miscellaneous:            "Miscellaneous"
        case .otherCases:               "Other cases"
        case .otherMembers:             "Other members in extension"
        case .otherModules:             "Other modules"
        case .otherProducts:            "Other products"
        case .otherRequirements:        "Other requirements"

        case .seeAlso:                  "See also"

        case .allCases:                 "Cases"
        case .allRequirements:          "Requirements"
        case .restatesRequirements:     "Restates"
        case .implementsRequirements:   "Implements"
        case .overrides:                "Overrides"
        case .superclasses:             "Superclasses"
        case .supertypes:               "Supertypes"
        }
    }
}
extension AutomaticHeading:HTML.OutputStreamableHeading
{
}
extension AutomaticHeading
{
    func window<T>(_ section:inout HTML.ContentEncoder,
        listing items:[T],
        limit:Int,
        open:Bool = false,
        with yield:(inout HTML.ContentEncoder, T) -> ())
    {
        section[.h2] = self

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
