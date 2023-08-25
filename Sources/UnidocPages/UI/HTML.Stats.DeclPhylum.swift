import HTML
import UnidocRecords

extension HTML.Stats
{
    struct DeclPhylum
    {
        let id:KeyPath<Record.Stats.Decl, Int>
        let domain:String
        let weight:Int

        init(_ id:KeyPath<Record.Stats.Decl, Int>, domain:String, weight:Int)
        {
            self.id = id
            self.domain = domain
            self.weight = weight
        }
    }
}
extension HTML.Stats.DeclPhylum
{
    private
    var what:String
    {
        switch self.id
        {
        case \.functions:       return "free functions or variables"
        case \.operators:       return "operators"
        case \.constructors:    return "initializers, type members, or enum cases"
        case \.methods:         return "instance methods"
        case \.subscripts:      return "instance subscripts"
        case \.functors:        return "functors"
        case \.protocols:       return "protocols"
        case \.requirements:    return "protocol requirements"
        case \.witnesses:       return "default implementations"
        case \.actors:          return "actors"
        case \.classes:         return "classes"
        case \.structures:      return "structures"
        case \.typealiases:     return "typealiases"
        default:                return "?"
        }
    }
}
extension HTML.Stats.DeclPhylum:PieValue
{
    var `class`:String?
    {
        switch self.id
        {
        case \.functions:       return "function"
        case \.operators:       return "operator"
        case \.constructors:    return "constructor"
        case \.methods:         return "method"
        case \.subscripts:      return "subscript"
        case \.functors:        return "functor"
        case \.protocols:       return "protocol"
        case \.requirements:    return "requirement"
        case \.witnesses:       return "witness"
        case \.actors:          return "actor"
        case \.classes:         return "class"
        case \.structures:      return "structure"
        case \.typealiases:     return "typealias"
        default:                return nil
        }
    }

    func legend(_ html:inout HTML.ContentEncoder, share:Double)
    {
        html += """
        \(share.percent) \(self.what)
        """
    }

    func label(share:Double) -> String
    {
        """
        \(share.percent) of the \(self.domain) are \(self.what)
        """
    }
}
