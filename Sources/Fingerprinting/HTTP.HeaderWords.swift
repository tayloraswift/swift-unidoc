import HTTP

extension HTTP
{
    @frozen @usableFromInline
    struct HeaderWords<Word, Separator> where Word:HeaderWord, Separator:HeaderWordSeparator
    {
        @usableFromInline
        var string:Substring
        @usableFromInline
        var index:String.Index

        @inlinable
        init(string:Substring)
        {
            self.string = string
            self.index = string.startIndex
        }
    }
}
extension HTTP.HeaderWords:IteratorProtocol
{
    @inlinable mutating
    func next() -> Word?
    {
        while self.index < self.string.endIndex
        {
            let start:String.Index = self.index
            let slice:Substring

            if  let end:String.Index = self.string[start...].firstIndex(of: Separator.character)
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
                let j:String.Index = slice[i...].lastIndex(where: { !$0.isWhitespace }),
                let word:Word = .init(slice[i ... j])
            {
                return word
            }
        }

        return nil
    }
}
