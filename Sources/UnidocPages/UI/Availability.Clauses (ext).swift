import Availability

extension Availability.Clauses<Availability.UniversalDomain>
{
    var notice:String?
    {
        guard case .unconditionally? = self.deprecated
        else
        {
            return nil
        }
        if  let name:String = self.renamed
        {
            return "This declaration is deprecated. It has been renamed to \(name)."
        }
        else if
            let message:String = self.message
        {
            return "This declaration is deprecated: \(message)"
        }
        else
        {
            return "This declaration is deprecated."
        }
    }
}
extension Availability.Clauses<Availability.AgnosticDomain>
{
    func notice(_ tool:String) -> String?
    {
        var prose:String
        switch (obsoleted: self.obsoleted, deprecated: self.deprecated)
        {
        case (obsoleted: let version?, _):
            prose = "This declaration was obsoleted in \(tool) \(version)"

        case (nil, deprecated: .since(let version?)?):
            prose = "This declaration was deprecated in \(tool) \(version)"

        case (nil, deprecated: .since(nil)?):
            prose = "This declaration is deprecated"

        case (nil, nil):
            return nil
        }

        if  let name:String = self.renamed
        {
            prose += ". It has been renamed to \(name)."
        }
        else if
            let message:String = self.message
        {
            prose += ": \(message)"
        }
        else
        {
            prose += "."
        }

        return prose
    }

    var badge:String?
    {
        self.introduced.map { "\($0)+" }
    }
}
extension Availability.Clauses<Availability.PlatformDomain>
{
    var badge:String?
    {
        switch
        (
            unavailable: self.unavailable,
            deprecated: self.deprecated,
            obsoleted: self.obsoleted,
            introduced: self.introduced
        )
        {
        case (unavailable: .unconditionally?, _, _, _):
            return "unavailable"

        case (nil, deprecated: _?, _, _):
            return "deprecated"

        case (nil, nil, obsoleted: _?, _):
            return "obsoleted"

        case (nil, nil, nil, introduced: let version?):
            return "\(version)+"

        case (nil, nil, nil, nil):
            return nil
        }
    }
}