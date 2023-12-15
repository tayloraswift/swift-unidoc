import HTML

extension HTML
{
    struct SourceLink:Equatable, Sendable
    {
        let file:Substring
        let line:Int?
        let target:String?

        init(file:Substring, line:Int? = nil, target:String?)
        {
            self.file = file
            self.line = line
            self.target = target
        }
    }
}
extension HTML.SourceLink:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[link: self.target]
        {
            $0.rel = .noopener
            $0.rel = .google_ugc
            $0.target = "_blank"
            $0.class = "source"
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
