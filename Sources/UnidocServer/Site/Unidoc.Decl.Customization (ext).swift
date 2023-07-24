import Unidoc

extension Unidoc.Decl.Customization
{
    var title:String?
    {
        switch self
        {
        case .unavailable:          return nil
        case .available:            return "Open."
        case .required:             return "Required."
        case .requiredOptionally:   return "Required optionally."
        }
    }

    var accent:String?
    {
        switch self
        {
        case .unavailable:          return nil
        case .available:            return "open"
        case .required:             return "required"
        case .requiredOptionally:   return "required"
        }
    }
}
