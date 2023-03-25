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
    class Actor:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .actor }
    }
}
extension Compiler
{
    final
    class InstanceMethod:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .instanceMethod }
    }
}
extension Compiler
{
    final
    class InstanceProperty:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .instanceProperty }
    }
}
extension Compiler
{
    final
    class InstanceSubscript:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .instanceSubscript }
    }
}
extension Compiler
{
    final
    class StaticMethod:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .typeMethod }
    }
}
extension Compiler
{
    final
    class StaticProperty:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .typeProperty }
    }
}
extension Compiler
{
    final
    class StaticSubscript:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .typeSubscript }
    }
}
extension Compiler
{
    final
    class StaticOperator:LatticeScalar
    {
        override class
        var phylum:SymbolPhylum { .typeOperator }
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
        var phylum:SymbolPhylum { .func }
    }
}
extension Compiler
{
    final
    class GlobalVar:Scalar
    {
        override class
        var phylum:SymbolPhylum { .var }
    }
}
extension Compiler
{
    final
    class GlobalOperator:Scalar
    {
        override class
        var phylum:SymbolPhylum { .operator }
    }
}
