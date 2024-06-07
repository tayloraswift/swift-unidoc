import HTML

extension Unidoc
{
    struct SourceLink:Equatable, Sendable
    {
        let target:String
        let icon:Icon
        let file:Substring
        let line:Int?

        init(target:String, icon:Icon, file:Substring, line:Int? = nil)
        {
            self.icon = icon
            self.file = file
            self.line = line
            self.target = target
        }
    }
}
extension Unidoc.SourceLink:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.a]
        {
            $0.rel = .google_ugc
            $0.href = self.target
            $0.target = "_blank"
            $0.class = "source \(self.icon.id)"
        }
            content:
        {
            $0[.span] { $0.class = "file" } = self.file

            if  let line:Int = self.line
            {
                $0 += ":"
                $0[.span] { $0.class = "line" } = "\(line + 1)"
            }
        }
    }
}
