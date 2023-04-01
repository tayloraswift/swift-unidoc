extension MarkdownInstruction
{
    /// An instruction that pushes a container element onto the document stack.
    @frozen public
    enum Push:UInt8, RawRepresentable, Equatable, Hashable, Sendable
    {
        case none = 0x00

        //  HTML elements.
        case a = 0x01
        case blockquote
        case code
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
        case comment = 0x20
        case identifier
        case keyword
        case literal
        case magic
        case actor
        case `class`
        case type
        case `typealias`

        //  Parameters section
        case parameters = 0x30

        //  Aside blocks.
        case attention = 0x31
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
        case returns
        case seealso
        case since
        case `throws`
        case tip
        case todo
        case version
        case warning
    }
}
extension MarkdownInstruction.Push:MarkdownInstructionType
{
    public
    typealias RawValue = UInt8
    
    @inlinable public static
    var marker:MarkdownBytecode.Marker { .push }
}
