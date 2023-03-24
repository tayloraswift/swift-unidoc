import SymbolColonies

extension Compiler
{
    public
    struct ExtensionSignatureError:Equatable, Error
    {
        public
        let expected:ExtensionSignature
        public
        let declared:[GenericConstraint<ScalarSymbolResolution>]?

        public
        init(expected:ExtensionSignature,
            declared:[GenericConstraint<ScalarSymbolResolution>]? = nil)
        {
            self.expected = expected
            self.declared = declared
        }
    }
}
extension Compiler.ExtensionSignatureError:CustomStringConvertible
{
    public
    var description:String
    {
        if  let _:[GenericConstraint<ScalarSymbolResolution>] = self.declared
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
