import SwiftSyntax

extension SignatureSyntax
{
    /// `Autographer`’s job is to produce the “autograph” of a type, which is an even more
    /// abridged form of the type’s signature. It is used for function signature disambiguation.
    struct Autographer
    {
        private
        let sugarMap:SugarMap
        private(set)
        var autograph:String

        init(sugaring sugarMap:SugarMap)
        {
            self.sugarMap = sugarMap
            self.autograph = ""
        }
    }
}
extension SignatureSyntax.Autographer
{
    mutating
    func encode(type:TypeSyntax)
    {
        if  let type:AttributedTypeSyntax = type.as(AttributedTypeSyntax.self)
        {
            self.encode(type: type.baseType)
        }
        else if
            let type:IdentifierTypeSyntax = type.as(IdentifierTypeSyntax.self)
        {
            self.encode(type: type.name, generics: type.genericArgumentClause?.arguments)
        }
        else if
            let type:MemberTypeSyntax = type.as(MemberTypeSyntax.self)
        {
            self.encode(type: type.baseType)
            self.autograph.append(".")
            self.encode(type: type.name, generics: type.genericArgumentClause?.arguments)
        }
        else if
            let type:ArrayTypeSyntax = type.as(ArrayTypeSyntax.self)
        {
            self.autograph.append("[")
            self.encode(type: type.element)
            self.autograph.append("]")
        }
        else if
            let type:DictionaryTypeSyntax = type.as(DictionaryTypeSyntax.self)
        {
            self.autograph.append("[")
            self.encode(type: type.key)
            self.autograph.append(":")
            self.encode(type: type.value)
            self.autograph.append("]")
        }
        else if
            let type:ImplicitlyUnwrappedOptionalTypeSyntax = type.as(
                ImplicitlyUnwrappedOptionalTypeSyntax.self)
        {
            self.encode(type: type.wrappedType)
            self.autograph.append("!")
        }
        else if
            let type:OptionalTypeSyntax = type.as(OptionalTypeSyntax.self)
        {
            self.encode(type: type.wrappedType)
            self.autograph.append("?")
        }
        else if
            let type:MetatypeTypeSyntax = type.as(MetatypeTypeSyntax.self)
        {
            self.encode(type: type.baseType)
            self.autograph.append(".Type")
        }
        else if
            let type:TupleTypeSyntax = type.as(TupleTypeSyntax.self)
        {
            self.autograph.append("(")

            var first:Bool = true
            for element:TupleTypeElementSyntax in type.elements
            {
                if  first
                {
                    first = false
                }
                else
                {
                    self.autograph.append(",")
                }
                self.encode(type: element.type)
            }

            self.autograph.append(")")
        }
        else if
            let function:FunctionTypeSyntax = type.as(FunctionTypeSyntax.self)
        {
            self.autograph.append("(")

            var first:Bool = true
            for parameter:TupleTypeElementSyntax in function.parameters
            {
                if  first
                {
                    first = false
                }
                else
                {
                    self.autograph.append(",")
                }

                self.encode(type: parameter.type)
            }

            self.autograph.append(")->")
            self.encode(type: function.returnClause.type)
        }
        else
        {
            self.autograph.append("_")
        }
    }

    private mutating
    func encode(type name:TokenSyntax, generics:GenericArgumentListSyntax?)
    {
        if  let generics:GenericArgumentListSyntax
        {
            let generics:[TypeSyntax] = generics.map(\.argument)
            let position:Int = name.positionAfterSkippingLeadingTrivia.utf8Offset

            if  self.sugarMap.arrays.contains(position), generics.count == 1
            {
                self.autograph.append("[")
                self.encode(type: generics[0])
                self.autograph.append("]")
                return
            }
            if  self.sugarMap.dictionaries.contains(position), generics.count == 2
            {
                self.autograph.append("[")
                self.encode(type: generics[0])
                self.autograph.append(":")
                self.encode(type: generics[1])
                self.autograph.append("]")
                return
            }
            if  self.sugarMap.optionals.contains(position), generics.count == 1
            {
                self.encode(type: generics[0])
                self.autograph.append("?")
                return
            }
        }
        else if name.text == "`Self`"
        {
            self.autograph.append("Self")
            return
        }

        self.autograph.append(name.text)
    }
}
