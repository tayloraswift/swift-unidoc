import Availability

extension Availability.Clauses<Availability.UniversalDomain> {
    var notice: String? {
        guard case .unconditionally? = self.deprecated else {
            return nil
        }
        if  let message: String = self.message {
            return "This declaration is deprecated: \(message)"
        } else {
            return "This declaration is deprecated."
        }
    }
}
extension Availability.Clauses<Availability.AgnosticDomain> {
    func notice(_ tool: String) -> String? {
        var prose: String
        switch (obsoleted: self.obsoleted, deprecated: self.deprecated) {
        case (obsoleted: let version?, _):
            prose = "This declaration was obsoleted in \(tool) \(version)"

        case (nil, deprecated: .since(let version?)?):
            prose = "This declaration was deprecated in \(tool) \(version)"

        case (nil, deprecated: .since(nil)?):
            prose = "This declaration is deprecated"

        case (nil, nil):
            return nil
        }

        if  let message: String = self.message {
            prose += ": \(message)"
        } else {
            prose += "."
        }

        return prose
    }

    var badge: String? {
        self.introduced.map { "\($0)+" }
    }
}
extension Availability.Clauses<Availability.PlatformDomain> {
    var badge: String? {
        switch (
            unavailable: self.unavailable,
            deprecated: self.deprecated,
            obsoleted: self.obsoleted,
            introduced: self.introduced
        ) {
        case (unavailable: .unconditionally?, _, _, _):
            "unavailable"

        case (nil, deprecated: _?, _, _):
            "deprecated"

        case (nil, nil, obsoleted: _?, _):
            "obsoleted"

        case (nil, nil, nil, introduced: let version?):
            "\(version)+"

        case (nil, nil, nil, nil):
            nil
        }
    }
}
