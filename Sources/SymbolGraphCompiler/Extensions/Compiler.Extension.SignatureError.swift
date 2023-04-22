import Generics
import SymbolGraphParts

extension Compiler.Extension
{
    public
    struct SignatureError:Equatable, Error
    {
        public
        let expected:Signature
        public
        let declared:[GenericConstraint<Symbol.Scalar>]?

        public
        init(expected:Signature,
            declared:[GenericConstraint<Symbol.Scalar>]? = nil)
        {
            self.expected = expected
            self.declared = declared
        }
    }
}
extension Compiler.Extension.SignatureError:CustomStringConvertible
{
    public
    var description:String
    {
        if  let _:[GenericConstraint<Symbol.Scalar>] = self.declared
        {
            return """
            Cannot declare an extension (of \(self.expected.type)) containing a \
            symbol with different extension constraints than its extension block.
            """
        }
        else
        {
            return """
            Cannot declare an extension (of \(self.expected.type)) containing a \
            relationship with different extension constraints than its extension \
            block.
            """
        }
    }
}
