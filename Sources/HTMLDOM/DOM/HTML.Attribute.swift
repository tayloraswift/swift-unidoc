extension HTML
{
    @frozen public
    enum Attribute:String, Equatable, Hashable, Sendable
    {
        case accept
        case acceptCharset = "accept-charset"
        case accesskey
        case action
        case align
        case allow
        case alt
        case async
        case autocapitalize
        case autocomplete
        case autofocus
        case autoplay
        case background
        case bgcolor
        case border
        case buffered
        case capture
        case challenge
        case charset
        case checked
        case cite
        case `class`
        case code
        case codebase
        case color
        case cols
        case colspan
        case content
        case contenteditable
        case contextmenu
        case controls
        case coords
        case crossorigin
        case csp
        case data
        case datetime
        case `default`
        case `defer`
        case dir
        case dirname
        case disabled
        case download
        case draggable
        case enctype
        case enterkeykint
        case `for`
        case form
        case formaction
        case formenctype
        case formmethod
        case formnovalidate
        case formtarget
        case headers
        case height
        case hidden
        case high
        case href
        case hreflang
        case httpEquiv = "http-equiv"
        case icon
        case id
        case importance
        case integrity
        case intrinsicsize
        case inputmode
        case ismap
        case itemprop
        case keytype
        case kind
        case label
        case lang
        case language
        case loading
        case list
        case loop
        case low
        case manifest
        case max
        case maxlength
        case minlength
        case media
        case method
        case min
        case multiple
        case muted
        case name
        case novalidate
        case open
        case optimum
        case pattern
        case ping
        case placeholder
        case poster
        case preload
        case radiogroup
        case readonly
        case referrerpolicy
        case rel
        case required
        case reversed
        case role
        case rows
        case rowspan
        case sandbox
        case scope
        case scoped
        case selected
        case shape
        case size
        case sizes
        case slot
        case span
        case spellcheck
        case src
        case srcdoc
        case srclang
        case srcset
        case start
        case step
        case style
        case summary
        case tabindex
        case target
        case title
        case translate
        case type
        case usemap
        case value
        case width
        case wrap

        @frozen public
        struct Factory
        {
            @inlinable internal init() {}

            @inlinable public var accept:Attribute          { .accept }
            @inlinable public var acceptCharset:Attribute   { .acceptCharset }
            @inlinable public var accesskey:Attribute       { .accesskey }
            @inlinable public var action:Attribute          { .action }
            @inlinable public var align:Attribute           { .align }
            @inlinable public var allow:Attribute           { .allow }
            @inlinable public var alt:Attribute             { .alt }
            @inlinable public var async:Attribute           { .async }
            @inlinable public var autocapitalize:Attribute  { .autocapitalize }
            @inlinable public var autocomplete:Attribute    { .autocomplete }
            @inlinable public var autofocus:Attribute       { .autofocus }
            @inlinable public var autoplay:Attribute        { .autoplay }
            @inlinable public var background:Attribute      { .background }
            @inlinable public var bgcolor:Attribute         { .bgcolor }
            @inlinable public var border:Attribute          { .border }
            @inlinable public var buffered:Attribute        { .buffered }
            @inlinable public var capture:Attribute         { .capture }
            @inlinable public var challenge:Attribute       { .challenge }
            @inlinable public var charset:Attribute         { .charset }
            @inlinable public var checked:Attribute         { .checked }
            @inlinable public var cite:Attribute            { .cite }
            @inlinable public var `class`:Attribute         { .class }
            @inlinable public var code:Attribute            { .code }
            @inlinable public var codebase:Attribute        { .codebase }
            @inlinable public var color:Attribute           { .color }
            @inlinable public var cols:Attribute            { .cols }
            @inlinable public var colspan:Attribute         { .colspan }
            @inlinable public var content:Attribute         { .content }
            @inlinable public var contenteditable:Attribute { .contenteditable }
            @inlinable public var contextmenu:Attribute     { .contextmenu }
            @inlinable public var controls:Attribute        { .controls }
            @inlinable public var coords:Attribute          { .coords }
            @inlinable public var crossorigin:Attribute     { .crossorigin }
            @inlinable public var csp:Attribute             { .csp }
            @inlinable public var data:Attribute            { .data }
            @inlinable public var datetime:Attribute        { .datetime }
            @inlinable public var `default`:Attribute       { .default }
            @inlinable public var `defer`:Attribute         { .defer }
            @inlinable public var dir:Attribute             { .dir }
            @inlinable public var dirname:Attribute         { .dirname }
            @inlinable public var disabled:Attribute        { .disabled }
            @inlinable public var download:Attribute        { .download }
            @inlinable public var draggable:Attribute       { .draggable }
            @inlinable public var enctype:Attribute         { .enctype }
            @inlinable public var enterkeykint:Attribute    { .enterkeykint }
            @inlinable public var `for`:Attribute           { .for }
            @inlinable public var form:Attribute            { .form }
            @inlinable public var formaction:Attribute      { .formaction }
            @inlinable public var formenctype:Attribute     { .formenctype }
            @inlinable public var formmethod:Attribute      { .formmethod }
            @inlinable public var formnovalidate:Attribute  { .formnovalidate }
            @inlinable public var formtarget:Attribute      { .formtarget }
            @inlinable public var headers:Attribute         { .headers }
            @inlinable public var height:Attribute          { .height }
            @inlinable public var hidden:Attribute          { .hidden }
            @inlinable public var high:Attribute            { .high }
            @inlinable public var href:Attribute            { .href }
            @inlinable public var hreflang:Attribute        { .hreflang }
            @inlinable public var httpEquiv:Attribute       { .httpEquiv }
            @inlinable public var icon:Attribute            { .icon }
            @inlinable public var id:Attribute              { .id }
            @inlinable public var importance:Attribute      { .importance }
            @inlinable public var integrity:Attribute       { .integrity }
            @inlinable public var intrinsicsize:Attribute   { .intrinsicsize }
            @inlinable public var inputmode:Attribute       { .inputmode }
            @inlinable public var ismap:Attribute           { .ismap }
            @inlinable public var itemprop:Attribute        { .itemprop }
            @inlinable public var keytype:Attribute         { .keytype }
            @inlinable public var kind:Attribute            { .kind }
            @inlinable public var label:Attribute           { .label }
            @inlinable public var lang:Attribute            { .lang }
            @inlinable public var language:Attribute        { .language }
            @inlinable public var loading:Attribute         { .loading }
            @inlinable public var list:Attribute            { .list }
            @inlinable public var loop:Attribute            { .loop }
            @inlinable public var low:Attribute             { .low }
            @inlinable public var manifest:Attribute        { .manifest }
            @inlinable public var max:Attribute             { .max }
            @inlinable public var maxlength:Attribute       { .maxlength }
            @inlinable public var minlength:Attribute       { .minlength }
            @inlinable public var media:Attribute           { .media }
            @inlinable public var method:Attribute          { .method }
            @inlinable public var min:Attribute             { .min }
            @inlinable public var multiple:Attribute        { .multiple }
            @inlinable public var muted:Attribute           { .muted }
            @inlinable public var name:Attribute            { .name }
            @inlinable public var novalidate:Attribute      { .novalidate }
            @inlinable public var open:Attribute            { .open }
            @inlinable public var optimum:Attribute         { .optimum }
            @inlinable public var pattern:Attribute         { .pattern }
            @inlinable public var ping:Attribute            { .ping }
            @inlinable public var placeholder:Attribute     { .placeholder }
            @inlinable public var poster:Attribute          { .poster }
            @inlinable public var preload:Attribute         { .preload }
            @inlinable public var radiogroup:Attribute      { .radiogroup }
            @inlinable public var readonly:Attribute        { .readonly }
            @inlinable public var referrerpolicy:Attribute  { .referrerpolicy }
            @available(*, unavailable,
                message: "Use the typed 'rel' property on 'HTML.AttributeEncoder' instead.")
            @inlinable public var rel:Attribute             { .rel }
            @inlinable public var required:Attribute        { .required }
            @inlinable public var reversed:Attribute        { .reversed }
            @inlinable public var role:Attribute            { .role }
            @inlinable public var rows:Attribute            { .rows }
            @inlinable public var rowspan:Attribute         { .rowspan }
            @inlinable public var sandbox:Attribute         { .sandbox }
            @inlinable public var scope:Attribute           { .scope }
            @inlinable public var scoped:Attribute          { .scoped }
            @inlinable public var selected:Attribute        { .selected }
            @inlinable public var shape:Attribute           { .shape }
            @inlinable public var size:Attribute            { .size }
            @inlinable public var sizes:Attribute           { .sizes }
            @inlinable public var slot:Attribute            { .slot }
            @inlinable public var span:Attribute            { .span }
            @inlinable public var spellcheck:Attribute      { .spellcheck }
            @inlinable public var src:Attribute             { .src }
            @inlinable public var srcdoc:Attribute          { .srcdoc }
            @inlinable public var srclang:Attribute         { .srclang }
            @inlinable public var srcset:Attribute          { .srcset }
            @inlinable public var start:Attribute           { .start }
            @inlinable public var step:Attribute            { .step }
            @inlinable public var style:Attribute           { .style }
            @inlinable public var summary:Attribute         { .summary }
            @inlinable public var tabindex:Attribute        { .tabindex }
            @inlinable public var target:Attribute          { .target }
            @inlinable public var title:Attribute           { .title }
            @inlinable public var translate:Attribute       { .translate }
            @inlinable public var type:Attribute            { .type }
            @inlinable public var usemap:Attribute          { .usemap }
            @inlinable public var value:Attribute           { .value }
            @inlinable public var width:Attribute           { .width }
            @inlinable public var wrap:Attribute            { .wrap }
        }
    }
}
