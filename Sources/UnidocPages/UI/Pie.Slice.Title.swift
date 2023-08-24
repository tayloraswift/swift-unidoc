import HTML

extension Pie.Slice
{
    struct Title
    {
        let text:String

        init(_ text:String)
        {
            self.text = text
        }
    }
}
extension Pie.Slice.Title:ScalableVectorOutputStreamable
{
    static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg[.title] = self.text.isEmpty ? nil : self.text
    }
}
