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
