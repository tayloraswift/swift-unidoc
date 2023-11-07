import SwiftSyntax
import SwiftSyntaxMacros

extension InlineASCII
{
    public
    struct ConstructorMacro
    {
    }
}
extension InlineASCII.ConstructorMacro:ExtensionMacro
{
    public static
    func expansion(of attachment:AttributeSyntax,
        attachedTo declaration:some DeclGroupSyntax,
        providingExtensionsOf subject:some TypeSyntaxProtocol,
        conformingTo protocols:[TypeSyntax],
        in context:some MacroExpansionContext) throws -> [ExtensionDeclSyntax]
    {
        if  let missing:TypeSyntax = protocols.first
        {
            context[.error, attachment] = """
            macro must be applied to a type that conforms to '\(missing)'
            """
            return []
        }

        guard
        let arguments:AttributeSyntax.Arguments = attachment.arguments
        else
        {
            context[.warning, attachment] = """
            macro contains no argument list, and will generate no constructors
            """
            return []
        }

        guard
        let arguments:LabeledExprListSyntax = arguments.as(LabeledExprListSyntax.self)
        else
        {
            throw PreconditionError.unreachable
        }

        if  arguments.isEmpty
        {
            context[.warning, attachment] = """
            macro contains no arguments, and will generate no constructors
            """
        }

        let constructors:[MemberBlockItemSyntax] = try arguments.map
        {
            guard
            let name:StringLiteralExprSyntax = .init($0.expression)
            else
            {
                throw PreconditionError.unreachable
            }

            let text:String = "\(name.segments)"
            let hex:String = text.utf8.reduce(into: "")
            {
                $0 += String.init($1 >> 4,   radix: 16)
                $0 += String.init($1 & 0x0F, radix: 16)
            }

            let decl:DeclSyntax = """
            @inlinable public static
            var `\(name.segments)`:Self { .init(rawValue: 0x\(raw: hex)) }
            """

            return .init(decl: decl)
        }

        let block:ExtensionDeclSyntax = .init(extendedType: subject,
            memberBlock: .init(members: .init(constructors)))

        return [block]
    }
}
