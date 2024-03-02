import Sources
import Symbols

public
protocol DiagnosticSymbolicator<Address>
{
    associatedtype Address

    subscript(article address:Address) -> Symbol.Article? { get }
    subscript(decl address:Address) -> Symbol.Decl? { get }
    subscript(file address:Address) -> Symbol.File? { get }

    var demangler:Demangler? { get }
    var root:Symbol.FileBase? { get }
}
extension DiagnosticSymbolicator
{
    /// Returns the demangled signature of the scalar symbol referenced by the given
    /// scalar. The scalar must refer to a declaration and not an article.
    @inlinable public
    subscript(address:Address) -> String
    {
        if  let symbol:Symbol.Article = self[article: address]
        {
            "'\(symbol.rawValue)'"
        }
        else if
            let symbol:Symbol.Decl = self[decl: address]
        {
            self.demangle(symbol)
        }
        else
        {
            "<unavailable>"
        }
    }

    @available(*, deprecated, renamed: "subscript(_:)")
    @inlinable public
    func signature(of scalar:Address) -> String
    {
        self[scalar]
    }

    @inlinable public
    func demangle(_ symbol:Symbol.Decl) -> String
    {
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
    func path(of scalar:Address) -> String?
    {
        if  let root:Symbol.FileBase = self.root,
            let file:Symbol.File = self[file: scalar]
        {
            "\(root.path)/\(file)"
        }
        else
        {
            nil
        }
    }
}
