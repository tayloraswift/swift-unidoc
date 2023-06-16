extension Unicode.Scalar
{
    @inlinable internal
    init?(_ string:Substring)
    {
        if  let codepoint:Unicode.Scalar = string.unicodeScalars.first,
                string.unicodeScalars.count == 1
        {
            self = codepoint
        }
        else
        {
            return nil
        }
    }
}
