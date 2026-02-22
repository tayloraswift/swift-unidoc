enum TerminalColor {
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
extension TerminalColor: CustomStringConvertible {
    var description: String {
        switch self {
        case .black:    "90"
        case .red:      "91"
        case .green:    "92"
        case .yellow:   "93"
        case .blue:     "94"
        case .magenta:  "95"
        case .cyan:     "96"
        case .white:    "97"

        case .rgb(let r, let g, let b):
            "38;2;\(r);\(g);\(b)"
        }
    }
}
