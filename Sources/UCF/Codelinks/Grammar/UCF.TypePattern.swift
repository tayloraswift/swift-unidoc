extension UCF
{
    final
    class TypePattern
    {
        let operand:TypeOperand
        let suffix:[TypeOperator]

        init(operand:TypeOperand, suffix:[TypeOperator])
        {
            self.operand = operand
            self.suffix = suffix
        }
    }
}
extension UCF.TypePattern
{
    /// Returns `self` unless `self` is the placeholder pattern `_`.
    var provided:UCF.TypePattern?
    {
        if  case .single(nil) = self.operand,
            self.suffix.isEmpty
        {
            return nil
        }
        else
        {
            return self
        }
    }

    var splatted:[UCF.TypePattern]
    {
        if  case .tuple(let tuple) = self.operand,
            self.suffix.isEmpty
        {
            return tuple
        }
        else
        {
            return [self]
        }
    }
}
extension UCF.TypePattern
{
    /// Formats this type pattern from an original source string as a normalized string
    /// representation.
    func formatted(source:Substring) -> String
    {
        var string:String = ""
        self.format(source: source, into: &string)
        return string
    }

    private
    func format(source:Substring, into string:inout String)
    {
        switch self.operand
        {
        case .bracket(let key, let value?):
            string.append("[")
            key.format(source: source, into: &string)
            string.append(":")
            value.format(source: source, into: &string)
            string.append("]")

        case .bracket(let element, nil):
            string.append("[")
            element.format(source: source, into: &string)
            string.append("]")

        case .closure(let inputs, let output):
            string.append("(")

            var first:Bool = true
            for input in inputs
            {
                if  first
                {
                    first = false
                }
                else
                {
                    string.append(",")
                }

                input.format(source: source, into: &string)
            }
            string.append(")->")
            output.format(source: source, into: &string)

        case .nominal(let path):
            var first:Bool = true
            for (component, generics):(Range<String.Index>, [UCF.TypePattern]) in path
            {
                if  first
                {
                    first = false
                }
                else
                {
                    string.append(".")
                }

                string += source[component]

                if  generics.isEmpty
                {
                    continue
                }

                string.append("<")
                var first:Bool = true
                for type:UCF.TypePattern in generics
                {
                    if  first
                    {
                        first = false
                    }
                    else
                    {
                        string.append(",")
                    }

                    type.format(source: source, into: &string)
                }
                string.append(">")
            }

        case .single(let type?):
            type.format(source: source, into: &string)

        case .single(nil):
            string.append("_")

        case .tuple(let tuple):
            string.append("(")
            var first:Bool = true
            for element:UCF.TypePattern in tuple
            {
                if  first
                {
                    first = false
                }
                else
                {
                    string.append(",")
                }

                element.format(source: source, into: &string)
            }
            string.append(")")
        }

        for postfix:UCF.TypeOperator in self.suffix
        {
            string.append(postfix.text)
        }
    }
}
