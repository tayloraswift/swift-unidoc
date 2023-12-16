extension URI.Path.Component
{
    @frozen public
    enum EncodingSet
    {
    }
}
extension URI.Path.Component.EncodingSet:PercentEncodingSet
{
    @inlinable public static
    func contains(_ byte:UInt8) -> Bool
    {
        switch byte
        {
        case    0x21,           // '!'
                0x24,           // '$'
                0x26,           // '&'
                0x27,           // '''
                0x28,           // '('
                0x29,           // ')'
                0x2a,           // '*'
                0x2b,           // '+'
                0x2c,           // ','
                0x2d,           // '-'
                0x2e,           // '.'
                0x30 ... 0x39,  // [0-9]
                0x3a,           // ':'
                0x3b,           // ';'
                0x3d,           // '='
                0x40,           // '@'
                0x41 ... 0x5a,  // [A-Z]
                0x5f,           // '_'
                0x61 ... 0x7a,  // [a-z]
                0x7e:           // '~'
            false

        case    _:
            true
        }
    }
}
