import Declarations
import JSONDecoding
import JSONEncoding

extension SymbolDescription
{
    //  https://github.com/apple/swift/blob/main/lib/SymbolGraphGen/DeclarationFragmentPrinter.cpp
    enum FragmentColor:String, Sendable
    {
        case attribute
        case binding = "internalParam"
        case identifier
        case keyword
        case label = "externalParam"

        //  let x:Int
        //     ^ ^
        case none = "text"

        case typeIdentifier

        case typeParameter = "genericParameter"
        case number
        case string
    }
}
extension SymbolDescription.FragmentColor:JSONDecodable, JSONEncodable
{
}
extension SymbolDescription.FragmentColor
{
    var classification:DeclarationFragmentClass?
    {
        switch self
        {
        case .attribute:        return .attribute
        case .binding:          return .binding
        case .identifier:       return .identifier
        case .keyword:          return .keyword
        case .label:            return .label
        case .none:             return nil
        case .typeIdentifier:   return .typeIdentifier
        case .typeParameter:    return .typeParameter
        case .number:           return .number
        case .string:           return .string
        }
    }
}
