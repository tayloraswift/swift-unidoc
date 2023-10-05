/// Defines the CSS classes associated with each type of supported syntax highlight.
///
/// The two-letter codenames make the Sass sources slightly less readable, but they reduce the
/// size of a typical rendered page by around 30 percent.
@frozen public
enum MarkdownSyntaxHighlight:String, Equatable, Hashable, Sendable
{
    case attribute      = "xa"
    case binding        = "xb"
    case comment        = "xc"
    case directive      = "xr"
    case doccomment     = "xd"
    case identifier     = "xv"
    case interpolation  = "xj"
    case keyword        = "xk"
    case label          = "xl"
    case literalNumber  = "xn"
    case literalString  = "xs"
    case magic          = "xm"
    case `operator`     = "xo"
    case pseudo         = "xp"
    case actor          = "xy"
    case `class`        = "xz"
    case type           = "xt"
    case `typealias`    = "xu"
    case indent         = "xi"
}
extension MarkdownSyntaxHighlight:CustomStringConvertible
{
    @inlinable public
    var description:String { self.rawValue }
}
