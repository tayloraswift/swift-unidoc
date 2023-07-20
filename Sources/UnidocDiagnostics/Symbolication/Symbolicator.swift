import ModuleGraphs
import Signatures
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
        if  let symbol:Symbol.Decl = self.loadDeclSymbol(scalar)
        {
            return self.signature(of: symbol)
        }
        else
        {
            return "<unavailable>"
        }
    }
    @inlinable public
    func signature(of symbol:Symbol.Decl) -> String
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
extension Symbolicator where Scalar:Hashable
{
    @inlinable public
    func constraints(_ constraints:[GenericConstraint<Scalar?>]) -> String
    {
        constraints.map
        {
            switch $0
            {
            case    .where(let parameter, is: .equal, to: .nominal(let type?)):
                return "\(parameter) == \(self.signature(of: type))"

            case    .where(let parameter, is: .equal, to: .nominal(nil)):
                return "\(parameter) == <unavailable>"

            case    .where(let parameter, is: .equal, to: .complex(let text)):
                return "\(parameter) == \(text)"

            case    .where(let parameter, is: .subclass, to: .nominal(let type?)),
                    .where(let parameter, is: .conformer, to: .nominal(let type?)):
                return "\(parameter):\(self.signature(of: type))"

            case    .where(let parameter, is: .subclass, to: .nominal(nil)),
                    .where(let parameter, is: .conformer, to: .nominal(nil)):
                return "\(parameter):<unavailable>"

            case    .where(let parameter, is: .subclass, to: .complex(let text)),
                    .where(let parameter, is: .conformer, to: .complex(let text)):
                return "\(parameter):\(text)"
            }
        }.joined(separator: ", ")
    }
}
