extension SnippetParser
{
    /// A snippet slice is an arbitrary collection of text ranges within a snippet’s source
    /// file. Snippet slices are not contiguous, but they should never overlap.
    ///
    /// The individual ranges can span multiple lines, but de-indentation (via ``punch(hole:)``)
    /// may further break multiline ranges into multiple single-line ranges.
    struct Slice
    {
        let id:String
        let line:Int
        var ranges:[Range<Int>]

        init(id:String, line:Int, ranges:[Range<Int>])
        {
            self.id = id
            self.line = line
            self.ranges = ranges
        }
    }
}
extension SnippetParser.Slice
{
    mutating
    func punch(hole:Range<Int>)
    {
        guard
        let last:Int = self.ranges.indices.last
        else
        {
            preconditionFailure("Punching a hole in an empty slice!")
        }

        let next:Range<Int>? =
        {
            if  $0.lowerBound < hole.lowerBound
            {
                let next:Range<Int>? = hole.upperBound < $0.upperBound
                    ? hole.upperBound ..< $0.upperBound
                    : nil

                $0 = $0.lowerBound ..< hole.lowerBound
                return next
            }
            else
            {
                precondition(hole.upperBound <= $0.upperBound,
                    "Punching a hole that is not inside the slice!")

                $0 = hole.upperBound ..< $0.upperBound
                return nil
            }
        } (&self.ranges[last])

        if  let next:Range<Int>
        {
            self.ranges.append(next)
        }
    }
}
