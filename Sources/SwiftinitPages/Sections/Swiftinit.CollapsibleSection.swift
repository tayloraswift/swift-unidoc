import HTML

extension Swiftinit
{
    struct CollapsibleSection<Body> where Body:HTML.OutputStreamable
    {
        let collapse:(count:Int, open:Bool)?
        let heading:AutomaticHeading
        let body:Body

        init(
            collapse:(count:Int, open:Bool)? = nil,
            heading:AutomaticHeading,
            body:Body)
        {
            self.collapse = collapse
            self.heading = heading
            self.body = body
        }
    }
}
extension Swiftinit.CollapsibleSection:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.h2] = self.heading

        guard
        let (count, open):(Int, Bool) = self.collapse
        else
        {
            section += self.body
            return
        }

        section[.details, { $0.open = open }]
        {
            $0[.summary]
            {
                $0[.p] { $0.class = "view" } = "View members"

                $0[.p] { $0.class = "hide" } = "Hide members"

                $0[.p, { $0.class = "reason" }]
                {
                    $0 += "This section is hidden by default because it contains too many "

                    $0[.span] { $0.class = "count" } = "(\(count))"

                    $0 += " members."
                }
            }

            $0 += self.body
        }
    }
}
