import Unidoc

extension Unidoc.Decl.Customization
{
    var title:String?
    {
        switch self
        {
        case .unavailable:          return nil
        case .available:            return "Customization available."
        case .required:             return "Required."
        case .requiredOptionally:   return "Required optionally."
        }
    }

    var accent:String
    {
        switch self
        {
        case .unavailable:          return "customization-unavailable"
        case .available:            return "customization-available"
        case .required:             return "required"
        case .requiredOptionally:   return "required"
        }
    }
}
