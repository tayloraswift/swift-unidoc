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
        Self.contains(codepoint: .init(byte))
    }
}
extension URI.Path.Component.EncodingSet
{
    @inlinable static
    func contains(codepoint:Unicode.Scalar) -> Bool
    {
        switch codepoint
        {
        case "!":           false
        case "$":           false
        case "&":           false
        case "'":           false
        case "(":           false
        case ")":           false
        case "*":           false
        case "+":           false
        case ",":           false
        case "-":           false
        case ".":           false
        case "0" ... "9":   false
        case ":":           false
        case ";":           false
        case "=":           false
        case "@":           false
        case "A" ... "Z":   false
        case "_":           false
        case "a" ... "z":   false
        case "~":           false
        default:            true
        }
    }
}
