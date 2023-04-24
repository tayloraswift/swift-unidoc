@frozen public
enum DeclarationFragmentClass:UInt8, Hashable, Equatable, Sendable
{
    //  @discardableResult
    //  ~~~~~~~~~~~~~~~~~^
    case attribute      = 0x01

    //  func f(x value:Int)
    //           ~~~~^
    case binding        = 0x02

    //  enum E
    //       ^
    case identifier     = 0x03

    //  func
    //  ~~~^
    case keyword        = 0x04

    //  func g(x:Int)
    //         ^
    case label          = 0x05

    //  func foo<T>(_:T)
    //                ^
    case typeIdentifier = 0x06

    //  func foo<T>(_:T)
    //           ^
    case typeParameter  = 0x07

    //  Defined by SymbolGraphGen, but never actually emitted:

    //  1989
    //  ~~~^
    case number         = 0x08

    //  "string"
    //  ~~~~~~~^
    case string         = 0x09
}
extension DeclarationFragmentClass:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .attribute:        return "a"
        case .binding:          return "b"
        case .identifier:       return "i"
        case .keyword:          return "k"
        case .label:            return "l"
        case .typeIdentifier:   return "t"
        case .typeParameter:    return "g"
        case .number:           return "n"
        case .string:           return "s"
        }
    }
}
