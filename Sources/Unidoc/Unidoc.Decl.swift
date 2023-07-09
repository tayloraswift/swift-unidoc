extension Unidoc
{
    @frozen public
    enum Decl:Hashable, Sendable
    {
        case  actor
        case `associatedtype`
        case `case`
        case `class`
        case  deinitializer
        case `enum`
        case `func`(Objectivity?)
        case  initializer
        case `operator`
        case `protocol`
        case `struct`
        case `subscript`(Objectivity)
        case `typealias`
        case `var`(Objectivity?)
    }
}
extension Unidoc.Decl
{
    @inlinable public
    var orientation:Orientation
    {
        switch self
        {
        case .case, .deinitializer, .func, .initializer, .operator, .subscript, .var:
            return .gay

        case .actor, .associatedtype, .class, .enum, .protocol, .struct, .typealias:
            return .straight
        }
    }
}
extension Unidoc.Decl:RawRepresentable
{
    @inlinable public
    init?(rawValue:UInt8)
    {
        switch rawValue
        {
        case 0x00:  self = .actor
        case 0x10:  self = .associatedtype
        case 0x20:  self = .case
        case 0x30:  self = .class
        case 0x40:  self = .deinitializer
        case 0x50:  self = .enum
        case 0x60:  self = .func(nil)
        case 0x61:  self = .func(.static)
        case 0x62:  self = .func(.class)
        case 0x63:  self = .func(.instance)
        case 0x70:  self = .initializer
        case 0x80:  self = .operator
        case 0x90:  self = .protocol
        case 0xA0:  self = .struct
        case 0xB1:  self = .subscript(.static)
        case 0xB2:  self = .subscript(.class)
        case 0xB3:  self = .subscript(.instance)
        case 0xC0:  self = .typealias
        case 0xD0:  self = .var(nil)
        case 0xD1:  self = .var(.static)
        case 0xD2:  self = .var(.class)
        case 0xD3:  self = .var(.instance)
        case    _:  return nil
        }
    }
    @inlinable public
    var rawValue:UInt8
    {
        switch self
        {
        case .actor:                return 0x00
        case .associatedtype:       return 0x10
        case .case:                 return 0x20
        case .class:                return 0x30
        case .deinitializer:        return 0x40
        case .enum:                 return 0x50
        case .func(nil):            return 0x60
        case .func(.static):        return 0x61
        case .func(.class):         return 0x62
        case .func(.instance):      return 0x63
        case .initializer:          return 0x70
        case .operator:             return 0x80
        case .protocol:             return 0x90
        case .struct:               return 0xA0
        case .subscript(.static):   return 0xB1
        case .subscript(.class):    return 0xB2
        case .subscript(.instance): return 0xB3
        case .typealias:            return 0xC0
        case .var(nil):             return 0xD0
        case .var(.static):         return 0xD1
        case .var(.class):          return 0xD2
        case .var(.instance):       return 0xD3
        }
    }
}
