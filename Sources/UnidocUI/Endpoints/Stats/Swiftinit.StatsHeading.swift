import HTML

extension Unidoc
{
    enum StatsHeading
    {
        case interfaceLayers
        case interfaceBreakdown
        case documentationCoverage
    }
}
extension Unidoc.StatsHeading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .interfaceLayers:          "ss:interface-layers"
        case .interfaceBreakdown:       "ss:interface-breakdown"
        case .documentationCoverage:    "ss:documentation-coverage"
        }
    }
}
extension Unidoc.StatsHeading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .interfaceLayers:          "Interface layers"
        case .interfaceBreakdown:       "Interface breakdown"
        case .documentationCoverage:    "Documentation coverage"
        }
    }
}
