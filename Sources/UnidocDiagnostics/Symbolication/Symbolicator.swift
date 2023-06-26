import ModuleGraphs
import Symbols

public
protocol Symbolicator<Scalar>
{
    associatedtype Scalar

    func loadDeclSymbol(_ scalar:Scalar) -> Symbol.Decl?
    func loadFileSymbol(_ scalar:Scalar) -> Symbol.File?

    var demangler:Demangler? { get }
    var root:Repository.Root? { get }
}
extension Symbolicator
{
    /// Returns the demangled signature of the scalar symbol referenced by the given
    /// scalar. The scalar must refer to a declaration and not an article.
    @inlinable public
    func signature(of scalar:Scalar) -> String
    {
        guard let symbol:Symbol.Decl = self.loadDeclSymbol(scalar)
        else
        {
            return "<unavailable>"
        }
        if  let demangled:String = self.demangler?.demangle(symbol)
        {
            return demangled
        }
        else
        {
            print("warning: demangling not supported on this platform!")
            return symbol.rawValue
        }
    }
    /// Returns the absolute path of the file referenced by the given file scalar.
    @inlinable public
    func path(of scalar:Scalar) -> String?
    {
        if  let root:Repository.Root = self.root,
            let file:Symbol.File = self.loadFileSymbol(scalar)
        {
            return "\(root.path)/\(file)"
        }
        else
        {
            return nil
        }
    }
}
