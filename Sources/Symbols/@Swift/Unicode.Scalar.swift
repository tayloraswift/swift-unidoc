extension Unicode.Scalar
{
    @inlinable internal
    init?(_ string:Substring)
    {
        if  let rawValue:Unicode.Scalar = string.unicodeScalars.first,
                string.unicodeScalars.count == 1
        {
            self = rawValue
        }
        else
        {
            return nil
        }
    }
}
