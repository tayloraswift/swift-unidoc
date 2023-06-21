enum TerminalColor
{
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white

    case rgb(UInt8, UInt8, UInt8)
}
extension TerminalColor:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .black:    return "90"
        case .red:      return "91"
        case .green:    return "92"
        case .yellow:   return "93"
        case .blue:     return "94"
        case .magenta:  return "95"
        case .cyan:     return "96"
        case .white:    return "97"

        case .rgb(let r, let g, let b):
            return "38;2;\(r);\(g);\(b)"
        }
    }
}
