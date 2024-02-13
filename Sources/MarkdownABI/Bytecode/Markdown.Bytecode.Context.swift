extension Markdown.Bytecode
{
    /// An instruction that pushes a container element onto the document stack.
    @frozen public
    enum Context:UInt8, RawRepresentable, Equatable, Hashable, Sendable
    {
        case transparent = 0x00

        //  HTML elements, native to Markdown.
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

        //  HTML elements, not native to Markdown.
        //
        //  New in 0.8.18. We don’t currently use most of these, but I would rather not keep
        //  adding non-contiguous cases to this enum.
        case html = 0x20
        case head
        case body
        case abbr
        case audio
        case b
        case bdi
        case bdo
        case address
        case article
        case aside
        case button
        case canvas
        case caption
        case colgroup
        case cite
        case data
        case datalist
        case del
        case details
        case dialog
        case dfn
        case div
        case embed
        case fieldset
        case figcaption
        case figure
        case footer
        case form
        case header
        case i
        case iframe
        case ins
        case kbd
        case label
        case legend
        case main
        case map
        case mark
        case menu
        case meter
        case nav
        case noscript
        case object
        case optgroup
        case option
        case output
        case picture
        case portal
        case progress
        case q
        case rp
        case rt
        case ruby
        case samp
        case small
        case section
        case span
        case select
        case slot
        case sub
        case summary
        case sup
        case template
        case textarea
        case tfoot
        case time
        case title
        case u
        case `var`
        case video

        //  Snippet pseudoelement.
        case snippet = 0x9F

        //  Syntax highlights.
        case attribute = 0xA0
        case binding
        case comment
        case directive
        case doccomment
        case identifier
        case interpolation
        case keyword
        case literalNumber
        case literalString
        case magic
        case `operator`
        case pseudo
        case actor
        case `class`
        case type
        case `typealias`
        /// New in 8.0.
        case indent

        //  Section elements.
        case parameters = 0xC0
        case returns
        case `throws`

        //  Signage elements.
        case attention = 0xD0
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
extension Markdown.Bytecode.Context
{
    /// Returns a heading context, clamping the given heading `level`. If
    /// `level` is less than 1, this function returns ``h1``. If `level`
    /// is greater than 6, this function returns ``h6``.
    @inlinable public static
    func h(_ level:Int) -> Self
    {
        switch level
        {
        case ...1:      .h1
        case    2:      .h2
        case    3:      .h3
        case    4:      .h4
        case    5:      .h5
        case    6, _:   .h6
        }
    }
}
