extension Pie
{
    @frozen public
    struct Value:Sendable
    {
        public
        var weight:Int
        public
        var label:(@Sendable (Double) -> String)?
        public
        var `class`:String

        @inlinable public
        init(weight:Int,
            class:String = "",
            label:(@Sendable (Double) -> String)? = nil)
        {
            self.weight = weight
            self.class = `class`
            self.label = label
        }
    }
}
extension Pie.Value
{
    func title(_ share:Double) -> Pie.Slice.Title
    {
        .init(self.label?(share) ?? "")
    }
}
