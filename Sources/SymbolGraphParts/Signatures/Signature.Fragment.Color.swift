import JSONDecoding
import MarkdownABI
import Signatures

extension Signature.Fragment
{
    //  https://github.com/apple/swift/blob/main/lib/SymbolGraphGen/DeclarationFragmentPrinter.cpp
    enum Color:String, Hashable, Equatable, Sendable
    {
        //  @discardableResult
        //  ~~~~~~~~~~~~~~~~~^
        case attribute

        //  func f(x value:Int)
        //           ~~~~^
        case binding = "internalParam"

        //  enum E
        //       ^
        case identifier

        //  func
        //  ~~~^
        case keyword

        //  func g(x:Int)
        //         ^
        case label = "externalParam"

        //  let x:Int
        //     ^ ^
        case text

        //  func foo<T>(_:T)
        //                ^
        case typeIdentifier

        //  func foo<T>(_:T)
        //           ^
        case typeParameter = "genericParameter"

        //  Defined by SymbolGraphGen, but never actually emitted:

        //  1989
        //  ~~~^
        case number

        //  "string"
        //  ~~~~~~~^
        case string
    }
}
extension Signature.Fragment.Color
{
    var highlight:MarkdownBytecode.Context?
    {
        switch self
        {
        case .attribute:        return .attribute
        case .binding:          return .binding
        case .identifier:       return .identifier
        case .keyword:          return .keyword
        case .label:            return .identifier
        case .text:             return nil
        case .typeIdentifier:   return .type
        case .typeParameter:    return .typealias
        case .number:           return .literalNumber
        case .string:           return .literalString
        }
    }
}
extension Signature.Fragment.Color:JSONDecodable
{
}
