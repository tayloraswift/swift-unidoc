import HTML

extension MarkdownElementContext
{
    /// A signage context, which typically renders as an `aside` HTML element.
    /// Most markdown “asides” are signage contexts, but we prefer the term
    /// “signage” in our markdown ABI, because semantic processing is supposed
    /// to leave them where they appear in the source document, like a sign post.
    /// (Semantic processing reorders some asides, like `returns`, to the top of
    /// the document.)
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
        case .attention:        "Attention"
        case .author:           "Author"
        case .authors:          "Authors"
        case .bug:              "Bug"
        case .complexity:       "Complexity"
        case .copyright:        "Copyright"
        case .date:             "Date"
        case .experiment:       "Experiment"
        case .important:        "Important"
        case .invariant:        "Invariant"
        case .mutating:         "Mutating Variant"
        case .nonmutating:      "Non-mutating Variant"
        case .note:             "Note"
        case .postcondition:    "Postcondition"
        case .precondition:     "Precondition"
        case .remark:           "Remark"
        case .requires:         "Requires"
        case .seealso:          "See Also"
        case .since:            "Since"
        case .tip:              "Tip"
        case .todo:             "To-do"
        case .version:          "Version"
        case .warning:          "Warning"
        }
    }
}
