import HTML

extension Swiftinit
{
    enum StatsHeading
    {
        case interfaceBreakdown
        case documentationCoverage
    }
}
extension Swiftinit.StatsHeading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .interfaceBreakdown:       "ss:interface-breakdown"
        case .documentationCoverage:    "ss:documentation-coverage"
        }
    }
}
extension Swiftinit.StatsHeading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .interfaceBreakdown:       "Interface breakdown"
        case .documentationCoverage:    "Documentation coverage"
        }
    }
}
