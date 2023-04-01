extension MarkdownKeyword
{
    @frozen public
    enum Aside:String, Equatable, Hashable, Sendable
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
        case returns
        case seealso
        case since
        case `throws`
        case tip
        case todo
        case version
        case warning
    }
}
extension MarkdownKeyword.Aside:CustomStringConvertible
{
    public
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
        case .returns:          return "Returns"
        case .seealso:          return "See Also"
        case .since:            return "Since"
        case .throws:           return "Throws"
        case .tip:              return "Tip"
        case .todo:             return "To-do"
        case .version:          return "Version"
        case .warning:          return "Warning"
        }
    }
}
extension MarkdownKeyword.Aside:MarkdownKeywordPattern
{
    public static
    var words:Int { 3 }
}
// extension MarkdownTree
// {
//     struct KeywordContainer
//     {
//     }
// }
