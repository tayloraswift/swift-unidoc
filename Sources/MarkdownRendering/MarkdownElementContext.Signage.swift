import HTML

extension MarkdownElementContext
{
    enum Signage:String, Equatable, Hashable, Sendable
    {
        case attention
        case author
        case authors
        case bug
        case complexity
        case copyright
        case date
        case experiment
        case important
        case invariant
        case mutating = "mutatingvariant"
        case nonmutating = "nonmutatingvariant"
        case note
        case postcondition
        case precondition
        case remark
        case requires
        case seealso
        case since
        case tip
        case todo
        case version
        case warning
    }
}
extension MarkdownElementContext.Signage:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .attention:        return "Attention"
        case .author:           return "Author"
        case .authors:          return "Authors"
        case .bug:              return "Bug"
        case .complexity:       return "Complexity"
        case .copyright:        return "Copyright"
        case .date:             return "Date"
        case .experiment:       return "Experiment"
        case .important:        return "Important"
        case .invariant:        return "Invariant"
        case .mutating:         return "Mutating Variant"
        case .nonmutating:      return "Non-mutating Variant"
        case .note:             return "Note"
        case .postcondition:    return "Postcondition"
        case .precondition:     return "Precondition"
        case .remark:           return "Remark"
        case .requires:         return "Requires"
        case .seealso:          return "See Also"
        case .since:            return "Since"
        case .tip:              return "Tip"
        case .todo:             return "To-do"
        case .version:          return "Version"
        case .warning:          return "Warning"
        }
    }
}
