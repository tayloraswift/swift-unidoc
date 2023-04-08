extension Codelink
{
    @frozen public
    struct Path
    {
        public
        var components:[String]
        public
        var collation:Collation?
        public
        var suffix:Suffix?

        private
        init()
        {
            self.components = []
            self.collation = nil
            self.suffix = nil
        }
    }
}
extension Codelink.Path
{
    init?(_ description:Substring)
    {
        var codepoints:Substring.UnicodeScalarView = description.unicodeScalars
        self.init(parsing: &codepoints)
        if !codepoints.isEmpty
        {
            return nil
        }
    }
    private
    init?(parsing codepoints:inout Substring.UnicodeScalarView)
    {
        self.init()

        while true
        {
            let component:String

            if      let identifier:Codelink.Identifier = .init(parsing: &codepoints)
            {
                component = identifier.description
            }
            else if let `operator`:Codelink.Operator = .init(parsing: &codepoints)
            {
                component = `operator`.description
            }
            else
            {
                return nil
            }

            let labels:Codelink.ArgumentLabels? = .init(parsing: &codepoints)

            switch (labels, codepoints.first)
            {
            case (nil, "/"?):
                self.collation = .legacy
                fallthrough
            
            case (nil, "."?):
                codepoints.removeFirst()

                self.components.append(component)
                continue
            
            case (_, "-"?):
                codepoints.removeFirst()

                self.collation = .legacy
                self.suffix = .init(.init(codepoints))
                fallthrough
            
            case (_, nil):
                self.components.append(component + (labels?.description ?? ""))
                return
            
            case (_, _?):
                return nil
            }
        }
    }
}
