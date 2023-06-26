import ModuleGraphs
import Symbols

public
protocol Symbolicator<Address>
{
    associatedtype Address

    func loadScalarSymbol(_ address:Address) -> ScalarSymbol?
    func loadFileSymbol(_ address:Address) -> FileSymbol?

    var demangler:Demangler? { get }
    var root:Repository.Root? { get }
}
extension Symbolicator
{
    /// Returns the demangled signature of the scalar symbol referenced by the given
    /// scalar address. The address must refer to a declaration and not an article.
    @inlinable public
    func signature(of address:Address) -> String
    {
        guard let symbol:ScalarSymbol = self.loadScalarSymbol(address)
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
    /// Returns the absolute path of the file referenced by the given file address.
    @inlinable public
    func path(of address:Address) -> String?
    {
        if  let root:Repository.Root = self.root,
            let file:FileSymbol = self.loadFileSymbol(address)
        {
            return "\(root.path)/\(file)"
        }
        else
        {
            return nil
        }
    }
}
