import HTTP

extension HTTP
{
    @frozen @usableFromInline
    struct AcceptStringIterator
    {
        @usableFromInline
        var string:String
        @usableFromInline
        var index:String.Index

        @inlinable
        init(string:String)
        {
            self.string = string
            self.index = string.startIndex
        }
    }
}
extension HTTP.AcceptStringIterator:IteratorProtocol
{
    @inlinable mutating
    func next() -> HTTP.AcceptStringParameter?
    {
        while self.index < self.string.endIndex
        {
            let start:String.Index = self.index
            let slice:Substring

            if  let end:String.Index = self.string[start...].firstIndex(of: ",")
            {
                self.index = self.string.index(after: end)
                slice = self.string[start ..< end]
            }
            else
            {
                self.index = self.string.endIndex
                slice = self.string[start...]
            }

            //  Skip components that are only whitespace.
            if  let i:String.Index = slice.firstIndex(where: { !$0.isWhitespace }),
                let j:String.Index = slice[i...].lastIndex(where: { !$0.isWhitespace })
            {
                return .init(slice[i ... j])
            }
        }

        return nil
    }
}
