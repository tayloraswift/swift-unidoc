import SwiftSyntax

extension SignatureSyntax
{
    @frozen @usableFromInline
    struct ExpandedVisitor
    {
        let sugarMap:SugarMap

        private(set)
        var inputs:[String]
        private(set)
        var output:[String]

        @usableFromInline
        init(sugaring sugarMap:SugarMap)
        {
            self.sugarMap = sugarMap
            self.inputs = []
            self.output = []
        }
    }
}
extension SignatureSyntax.ExpandedVisitor:SignatureVisitor
{
    mutating
    func register(
        parameter:FunctionParameterSyntax,
        type _:SignatureParameterType) -> SignatureSyntax.ExpandedParameter
    {
        var autographer:SignatureSyntax.Autographer = .init(sugaring: self.sugarMap)
        autographer.encode(type: parameter.type)
        inputs.append(autographer.autograph)
        return .init(syntax: parameter)
    }

    mutating
    func register(returns:TypeSyntax)
    {
        guard
        let tuple:TupleTypeSyntax = returns.as(TupleTypeSyntax.self)
        else
        {
            self.register(output: returns)
            return
        }

        for element:TupleTypeElementSyntax in tuple.elements
        {
            self.register(output: element.type)
        }
    }
}
extension SignatureSyntax.ExpandedVisitor
{
    private mutating
    func register(output:TypeSyntax)
    {
        var autographer:SignatureSyntax.Autographer = .init(sugaring: self.sugarMap)
        autographer.encode(type: output)
        self.output.append(autographer.autograph)
    }
}
