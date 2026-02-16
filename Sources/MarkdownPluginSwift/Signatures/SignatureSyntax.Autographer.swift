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
    func encode(parameter:FunctionParameterSyntax)
    {
        self.encode(type: parameter.type)

        if  case _? = parameter.ellipsis
        {
            self.autograph.append("...")
        }
    }

    mutating
    func encode(type:GenericArgumentSyntax.Argument, stem:Bool = false)
    {
        switch type
        {
        case .type(let type):
            self.encode(type: type, stem: stem)

        case .expr:
            self.autograph.append("_")
        }
    }
    mutating
    func encode(type:TypeSyntax, stem:Bool = false)
    {
        if  let type:AttributedTypeSyntax = type.as(AttributedTypeSyntax.self)
        {
            self.encode(type: type.baseType)
        }
        else if
            let type:SomeOrAnyTypeSyntax = type.as(SomeOrAnyTypeSyntax.self)
        {
            self.encode(type: type.constraint)
        }
        else if
            let type:PackElementTypeSyntax = type.as(PackElementTypeSyntax.self)
        {
            self.encode(type: type.pack)
        }
        else if
            let type:PackExpansionTypeSyntax = type.as(PackExpansionTypeSyntax.self)
        {
            self.encode(type: type.repetitionPattern)
        }
        else if
            let type:IdentifierTypeSyntax = type.as(IdentifierTypeSyntax.self)
        {
            self.encode(type: type.name,
                arguments: type.genericArgumentClause?.arguments,
                resugar: !stem)
        }
        else if
            let type:MemberTypeSyntax = type.as(MemberTypeSyntax.self)
        {
            self.encode(type: type.baseType, stem: true)
            self.autograph.append(".")
            self.encode(type: type.name,
                arguments: type.genericArgumentClause?.arguments,
                resugar: false)
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
            let suppressed:SuppressedTypeSyntax = type.as(SuppressedTypeSyntax.self)
        {
            self.autograph.append("~")
            self.encode(type: suppressed.type)
        }
        else if
            let type:TupleTypeSyntax = type.as(TupleTypeSyntax.self)
        {
            if  let only:TupleTypeElementSyntax = type.elements.first, type.elements.count == 1
            {
                self.encode(type: only.type)
                return
            }

            self.autograph.append("(")

            /// We don’t rely on the existence of the trailing comma in the syntax tree, because
            /// Swift now allows trailing commas in many places, and we want to normalize them.
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
        else if
            let type:CompositionTypeSyntax = type.as(CompositionTypeSyntax.self)
        {
            var first:Bool = true
            for element:CompositionTypeElementSyntax in type.elements
            {
                if  first
                {
                    first = false
                }
                else
                {
                    self.autograph.append("&")
                }

                self.encode(type: element.type)
            }
        }
        else
        {
            self.autograph.append("_")
        }
    }

    private mutating
    func encode(type name:TokenSyntax, arguments:GenericArgumentListSyntax?, resugar:Bool)
    {
        if  let arguments:GenericArgumentListSyntax, resugar
        {
            let arguments:[GenericArgumentSyntax.Argument] = arguments.map(\.argument)
            let position:Int = name.positionAfterSkippingLeadingTrivia.utf8Offset

            if  self.sugarMap.arrays.contains(position), arguments.count == 1
            {
                self.autograph.append("[")
                self.encode(type: arguments[0])
                self.autograph.append("]")
                return
            }
            if  self.sugarMap.dictionaries.contains(position), arguments.count == 2
            {
                self.autograph.append("[")
                self.encode(type: arguments[0])
                self.autograph.append(":")
                self.encode(type: arguments[1])
                self.autograph.append("]")
                return
            }
            if  self.sugarMap.optionals.contains(position), arguments.count == 1
            {
                self.encode(type: arguments[0])
                self.autograph.append("?")
                return
            }
        }
        else if name.text == "`Self`"
        {
            /// This is serendipitously safe because if `Self` is dynamic or has been shadowed
            /// by a generic parameter, it will appear without the enclosing backticks, even if
            /// the original source code included unnecessary backticks.
            self.autograph.append(self.sugarMap.staticSelf ?? "Self")
            return
        }

        self.autograph.append(name.text)

        if  let arguments:GenericArgumentListSyntax
        {
            self.autograph.append("<")

            var first:Bool = true
            for type:GenericArgumentSyntax in arguments
            {
                if  first
                {
                    first = false
                }
                else
                {
                    self.autograph.append(",")
                }

                self.encode(type: type.argument)
            }

            self.autograph.append(">")
        }
    }
}
