import Signatures
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
    func symbolicate(_ diagnostics:consuming DiagnosticContext<Self>) -> [DiagnosticMessage]
    {
        var output:DiagnosticOutput<Self> = .init(symbolicator: self)
        for group:DiagnosticContext<Self>.Group in diagnostics.unsymbolicated
        {
            switch group
            {
            case .contextual(let diagnostic, location: let location, context: let context):
                defer
                {
                    output.append(diagnostic, with: context)
                }
                guard
                let location:SourceLocation<Self.Address> = location
                else
                {
                    continue
                }

                if  let file:String = self.path(of: location.file)
                {
                    output.messages.append(.sourceLocation(.init(
                        position: location.position,
                        file: file)))
                }
                else
                {
                    output.messages.append(.sourceLocation(nil))
                }

            case .general(let diagnostic):
                output.append(diagnostic, with: .init())
            }
        }

        return output.messages
    }
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
extension DiagnosticSymbolicator where Address:Hashable
{
    @inlinable public
    func constraints(_ constraints:[GenericConstraint<Address?>]) -> String
    {
        constraints.map
        {
            switch $0
            {
            case    .where(let parameter, is: .equal, to: .nominal(let type?)):
                "\(parameter) == \(self[type])"

            case    .where(let parameter, is: .equal, to: .nominal(nil)):
                "\(parameter) == <unavailable>"

            case    .where(let parameter, is: .equal, to: .complex(let text)):
                "\(parameter) == \(text)"

            case    .where(let parameter, is: .subclass, to: .nominal(let type?)),
                    .where(let parameter, is: .conformer, to: .nominal(let type?)):
                "\(parameter):\(self[type])"

            case    .where(let parameter, is: .subclass, to: .nominal(nil)),
                    .where(let parameter, is: .conformer, to: .nominal(nil)):
                "\(parameter):<unavailable>"

            case    .where(let parameter, is: .subclass, to: .complex(let text)),
                    .where(let parameter, is: .conformer, to: .complex(let text)):
                "\(parameter):\(text)"
            }
        }.joined(separator: ", ")
    }
}
