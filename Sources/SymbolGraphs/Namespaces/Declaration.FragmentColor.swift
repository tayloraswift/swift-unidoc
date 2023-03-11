import JSONDecoding
import JSONEncoding

extension Declaration
{
    //  https://github.com/apple/swift/blob/main/lib/SymbolGraphGen/DeclarationFragmentPrinter.cpp
    @frozen public
    enum FragmentColor:String, Sendable
    {
        //  @discardableResult
        //  ~~~~~~~~~~~~~~~~~^
        case attribute

        //  func f(x value:Int)
        //              ~~~~^
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
        case none = "text"

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
extension Declaration.FragmentColor:JSONDecodable, JSONEncodable
{
}
