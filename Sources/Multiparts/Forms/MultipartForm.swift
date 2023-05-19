@frozen public
struct MultipartForm
{
    public
    let parts:MultipartView

    private
    init(parts:MultipartView)
    {
        self.parts = parts
    }
}
extension MultipartForm:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(base: self.parts.makeIterator())
    }
}
extension MultipartForm
{
    public
    init(splitting message:[UInt8], on boundary:String) throws
    {
        self.init(parts: try .init(splitting: message, on: boundary))
    }
}
