import HTML

extension PieSlice
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
extension PieSlice.Title:ScalableVectorOutputStreamable
{
    static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg[.title] = self.text.isEmpty ? nil : self.text
    }
}
