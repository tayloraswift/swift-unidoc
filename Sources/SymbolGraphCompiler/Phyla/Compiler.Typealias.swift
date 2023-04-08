//  TODO: break up this file
extension Compiler
{
    final
    class Typealias:LatticeScalar
    {
    }
}
extension Compiler
{
    final
    class Enum:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .enum }
    }
}
extension Compiler
{
    final
    class EnumCase:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .case }
    }
}
extension Compiler
{
    final
    class Deinit:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .deinitializer }
    }
}
extension Compiler
{
    final
    class Init:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .initializer }
    }
}
extension Compiler
{
    final
    class Struct:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .struct }
    }
}
extension Compiler
{
    final
    class Class:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .class }
    }
}
extension Compiler
{
    final
    class ClassFunc:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .func(.class) }
    }
}
extension Compiler
{
    final
    class ClassVar:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .var(.class) }
    }
}
extension Compiler
{
    final
    class ClassSubscript:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .subscript(.class) }
    }
}
extension Compiler
{
    final
    class Actor:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .actor }
    }
}
extension Compiler
{
    final
    class InstanceFunc:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .func(.instance) }
    }
}
extension Compiler
{
    final
    class InstanceVar:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .var(.instance) }
    }
}
extension Compiler
{
    final
    class InstanceSubscript:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .subscript(.instance) }
    }
}
extension Compiler
{
    final
    class StaticFunc:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .func(.static) }
    }
}
extension Compiler
{
    final
    class StaticVar:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .var(.static) }
    }
}
extension Compiler
{
    final
    class StaticSubscript:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .subscript(.static) }
    }
}

extension Compiler
{
    final
    class AssociatedType:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .associatedtype }
    }
}

extension Compiler
{
    final
    class GlobalFunc:Scalar
    {
        override class
        var phylum:SymbolPhylum { .func(nil) }
    }
}
extension Compiler
{
    final
    class GlobalVar:Scalar
    {
        override class
        var phylum:SymbolPhylum { .var(nil) }
    }
}
extension Compiler
{
    final
    class Operator:Scalar
    {
        override class
        var phylum:SymbolPhylum { .operator }
    }
}
