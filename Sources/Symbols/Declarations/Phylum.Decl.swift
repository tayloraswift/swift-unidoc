extension Phylum
{
    @frozen public
    enum Decl:Hashable, Equatable, Sendable
    {
        case  actor
        case `associatedtype`
        case `case`
        case `class`
        case  deinitializer
        case `enum`
        case `func`(Objectivity?)
        case  initializer
        case  macro(Macro)
        case `operator`
        case `protocol`
        case `struct`
        case `subscript`(Objectivity)
        case `typealias`
        case `var`(Objectivity?)
    }
}
extension Phylum.Decl
{
    @inlinable public
    var objectivity:Objectivity?
    {
        switch self
        {
        case .actor:                    nil
        case .associatedtype:           nil
        case .case:                     .static
        case .class:                    nil
        case .deinitializer:            .instance
        case .enum:                     nil
        case .func(let self):           self
        case .initializer:              .static
        case .macro:                    nil
        case .operator:                 .static
        case .protocol:                 nil
        case .struct:                   nil
        case .subscript(let self):      self
        case .typealias:                nil
        case .var(let self):            self
        }
    }

    /// Indicates if the declaration is typelike. This is not the same as ``orientation``!
    @inlinable public
    var isTypelike:Bool
    {
        switch self
        {
        case    .actor,
                .associatedtype,
                .class,
                .enum,
                .macro,
                .protocol,
                .struct,
                .typealias:
            true

        case    .case,
                .deinitializer,
                .func,
                .initializer,
                .operator,
                .subscript,
                .var:
            false
        }
    }

    /// The declaration’s orientation. This is not the same as ``isTypelike``!
    @inlinable public
    var orientation:Orientation
    {
        switch self
        {
        case .case, .deinitializer, .func, .initializer, .operator, .subscript, .var:
            .gay

        case .macro(.freestanding):
            .gay

        case .macro(.attached):
            .straight

        case .actor, .associatedtype, .class, .enum, .protocol, .struct, .typealias:
            .straight
        }
    }
}
extension Phylum.Decl:RawRepresentable
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
        case 0xE0:  self = .macro(.attached)
        case 0xE1:  self = .macro(.freestanding)
        case    _:  return nil
        }
    }
    @inlinable public
    var rawValue:UInt8
    {
        switch self
        {
        case .actor:                0x00
        case .associatedtype:       0x10
        case .case:                 0x20
        case .class:                0x30
        case .deinitializer:        0x40
        case .enum:                 0x50
        case .func(nil):            0x60
        case .func(.static):        0x61
        case .func(.class):         0x62
        case .func(.instance):      0x63
        case .initializer:          0x70
        case .operator:             0x80
        case .protocol:             0x90
        case .struct:               0xA0
        case .subscript(.static):   0xB1
        case .subscript(.class):    0xB2
        case .subscript(.instance): 0xB3
        case .typealias:            0xC0
        case .var(nil):             0xD0
        case .var(.static):         0xD1
        case .var(.class):          0xD2
        case .var(.instance):       0xD3
        case .macro(.attached):     0xE0
        case .macro(.freestanding): 0xE1
        }
    }
}
