extension MarkdownBytecode
{
    /// An instruction that pushes a container element onto the document stack.
    @frozen public
    enum Context:UInt8, RawRepresentable, Equatable, Hashable, Sendable
    {
        case transparent = 0x00

        //  HTML elements.
        case a = 0x01
        case blockquote
        case code
        case dd
        case dl
        case dt
        case em
        case li
        case h1
        case h2
        case h3
        case h4
        case h5
        case h6
        case ol
        case p
        case pre
        case s
        case strong
        case table
        case tbody
        case thead
        case td
        case th
        case tr
        case ul

        //  Syntax highlights.
        case attribute = 0x20
        case binding
        case comment
        case identifier
        case interpolation
        case keyword
        case literal
        case magic
        case actor
        case `class`
        case type
        case `typealias`

        //  Section elements.
        case parameters = 0x30
        case returns
        case `throws`

        //  Signage elements.
        case attention = 0x40
        case author
        case authors
        case bug
        case complexity
        case copyright
        case date
        case experiment
        case important
        case invariant
        case mutating
        case nonmutating
        case note
        case postcondition
        case precondition
        case remark
        case requires
        case seealso
        case since
        case tip
        case todo
        case version
        case warning
    }
}
extension MarkdownBytecode.Context
{
    /// Returns a heading context, clamping the given heading `level`. If
    /// `level` is less than 1, this function returns ``h1``. If `level`
    /// is greater than 6, this function returns ``h6``.
    @inlinable public static
    func h(_ level:Int) -> Self
    {
        switch level
        {
        case ...1:      return .h1
        case    2:      return .h2
        case    3:      return .h3
        case    4:      return .h4
        case    5:      return .h5
        case    6, _:   return .h6
        }
    }
}
