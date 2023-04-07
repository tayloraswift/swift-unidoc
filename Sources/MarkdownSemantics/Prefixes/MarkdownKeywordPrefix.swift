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
    var context:MarkdownBytecode.Context
    {
        switch self
        {
        case .attention:        return .attention
        case .author:           return .author
        case .authors:          return .authors
        case .bug:              return .bug
        case .complexity:       return .complexity
        case .copyright:        return .copyright
        case .date:             return .date
        case .experiment:       return .experiment
        case .important:        return .important
        case .invariant:        return .invariant
        case .mutating:         return .mutating
        case .nonmutating:      return .nonmutating
        case .note:             return .note
        case .parameters:       return .parameters
        case .postcondition:    return .postcondition
        case .precondition:     return .precondition
        case .remark:           return .remark
        case .requires:         return .requires
        case .returns:          return .returns
        case .seealso:          return .seealso
        case .since:            return .since
        case .throws:           return .throws
        case .tip:              return .tip
        case .todo:             return .todo
        case .version:          return .version
        case .warning:          return .warning
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
