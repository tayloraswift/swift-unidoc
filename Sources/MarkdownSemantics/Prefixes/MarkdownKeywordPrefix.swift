import MarkdownABI
import MarkdownTrees

@frozen public
enum MarkdownKeywordPrefix:String, Equatable, Hashable, Sendable
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
    case parameters
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
extension MarkdownKeywordPrefix
{
    func callAsFunction(_ discussion:__owned [MarkdownTree.Block]) -> MarkdownTree.Block
    {
        switch self
        {
        case .attention:        return MarkdownDocumentation.Attention.init(discussion)
        case .author:           return MarkdownDocumentation.Author.init(discussion)
        case .authors:          return MarkdownDocumentation.Authors.init(discussion)
        case .bug:              return MarkdownDocumentation.Bug.init(discussion)
        case .complexity:       return MarkdownDocumentation.Complexity.init(discussion)
        case .copyright:        return MarkdownDocumentation.Copyright.init(discussion)
        case .date:             return MarkdownDocumentation.Date.init(discussion)
        case .experiment:       return MarkdownDocumentation.Experiment.init(discussion)
        case .important:        return MarkdownDocumentation.Important.init(discussion)
        case .invariant:        return MarkdownDocumentation.Invariant.init(discussion)
        case .mutating:         return MarkdownDocumentation.Mutating.init(discussion)
        case .nonmutating:      return MarkdownDocumentation.Nonmutating.init(discussion)
        case .note:             return MarkdownDocumentation.Note.init(discussion)
        case .parameters:       return MarkdownDocumentation.Parameters.init(discussion)
        case .postcondition:    return MarkdownDocumentation.Postcondition.init(discussion)
        case .precondition:     return MarkdownDocumentation.Precondition.init(discussion)
        case .remark:           return MarkdownDocumentation.Remark.init(discussion)
        case .requires:         return MarkdownDocumentation.Requires.init(discussion)
        case .returns:          return MarkdownDocumentation.Returns.init(discussion)
        case .seealso:          return MarkdownDocumentation.SeeAlso.init(discussion)
        case .since:            return MarkdownDocumentation.Since.init(discussion)
        case .throws:           return MarkdownDocumentation.Throws.init(discussion)
        case .tip:              return MarkdownDocumentation.Tip.init(discussion)
        case .todo:             return MarkdownDocumentation.ToDo.init(discussion)
        case .version:          return MarkdownDocumentation.Version.init(discussion)
        case .warning:          return MarkdownDocumentation.Warning.init(discussion)
        }
    }
}
extension MarkdownKeywordPrefix:MarkdownSemanticPrefix
{
    /// If a keyword pattern uses formatting, the formatting must apply
    /// to the entire pattern.
    static
    var radius:Int { 2 }

    init?(from elements:__shared [MarkdownTree.InlineBlock])
    {
        if  elements.count == 1
        {
            self.init(elements[0].text)
        }
        else
        {
            return nil
        }
    }

    private
    init?(_ description:String)
    {
        var lowercased:String = ""
            lowercased.reserveCapacity(description.utf8.count)
        var words:Int = 0
        for character:Character in description
        {
            if      character.isLetter
            {
                lowercased.append(character.lowercased())
            }
            //  Limit to 3 words, because the ``nonmutating`` keyphrase
            //  can be written as 'Non-mutating variant'.
            else if character == " " || 
                    character == "-",
                    words < 3
            {
                words += 1
                continue
            }
            else
            {
                return nil
            }
        }
        self.init(rawValue: lowercased)
    }
}
