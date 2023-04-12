public
protocol LexicalContinuation:CustomStringConvertible
{
    /// Returns the string value of this component, with encasing backticks if
    /// present or needed.
    var description:String { get }
    /// Returns the string value of this component, without any encasing backticks.
    var unencased:String { get }
}
