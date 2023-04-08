extension Codelink
{
    struct ArgumentLabels:Equatable, Hashable, Sendable
    {
        var characters:String

        private
        init()
        {
            self.characters = ""
        }
    }
}
extension Codelink.ArgumentLabels
{
    var description:String
    {
        self.characters.isEmpty ? "" : "(\(self.characters))"
    }
}
extension Codelink.ArgumentLabels
{
    init?(parsing codepoints:inout Substring.UnicodeScalarView)
    {
        var remaining:Substring.UnicodeScalarView = codepoints

        if case "("? = remaining.popFirst()
        {
            self.init()
        }
        else
        {
            return nil
        }

        while let label:Codelink.Identifier = .init(parsing: &remaining)
        {
            if  case ":"? = remaining.popFirst()
            {
                self.characters += label.characters
                self.characters.append(":")
            }
            else
            {
                return nil
            }
        }

        if case ")"? = remaining.popFirst()
        {
            codepoints = remaining
        }
        else
        {
            return nil
        }
    }
}
