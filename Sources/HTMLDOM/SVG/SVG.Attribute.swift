extension SVG
{
    @frozen public
    enum Attribute:String, Equatable, Hashable, Sendable
    {
        case accentHeight                       = "accent-height"
        case accumulate                         = "accumulate"
        case additive                           = "additive"
        case alignmentBaseline                  = "alignment-baseline"
        case alphabetic                         = "alphabetic"
        case amplitude                          = "amplitude"
        case arabicForm                         = "arabic-form"
        case ascent                             = "ascent"
        case attributeName                      = "attributeName"
        case attributeType                      = "attributeType"
        case azimuth                            = "azimuth"
        case baseFrequency                      = "baseFrequency"
        case baselineShift                      = "baseline-shift"
        case baseProfile                        = "baseProfile"
        case bbox                               = "bbox"
        case begin                              = "begin"
        case bias                               = "bias"
        case by                                 = "by"
        case calcMode                           = "calcMode"
        case capHeight                          = "cap-height"
        case `class`                            = "class"
        case clip                               = "clip"
        case clipPathUnits                      = "clipPathUnits"
        case clipPath                           = "clip-path"
        case clipRule                           = "clip-rule"
        case color                              = "color"
        case colorInterpolation                 = "color-interpolation"
        case colorInterpolationFilters          = "color-interpolation-filters"
        case colorProfile                       = "color-profile"
        case colorRendering                     = "color-rendering"
        case contentScriptType                  = "contentScriptType"
        case contentStyleType                   = "contentStyleType"
        case crossorigin                        = "crossorigin"
        case cursor                             = "cursor"
        case cx                                 = "cx"
        case cy                                 = "cy"
        case d                                  = "d"
        case decelerate                         = "decelerate"
        case descent                            = "descent"
        case diffuseConstant                    = "diffuseConstant"
        case direction                          = "direction"
        case display                            = "display"
        case divisor                            = "divisor"
        case dominantBaseline                   = "dominant-baseline"
        case dur                                = "dur"
        case dx                                 = "dx"
        case dy                                 = "dy"
        case edgeMode                           = "edgeMode"
        case elevation                          = "elevation"
        case enableBackground                   = "enable-background"
        case end                                = "end"
        case exponent                           = "exponent"
        case fill                               = "fill"
        case fillOpacity                        = "fill-opacity"
        case fillRule                           = "fill-rule"
        case filter                             = "filter"
        case filterRes                          = "filterRes"
        case filterUnits                        = "filterUnits"
        case floodColor                         = "flood-color"
        case floodOpacity                       = "flood-opacity"
        case fontFamily                         = "font-family"
        case fontSize                           = "font-size"
        case fontSizeAdjust                     = "font-size-adjust"
        case fontStretch                        = "font-stretch"
        case fontStyle                          = "font-style"
        case fontVariant                        = "font-variant"
        case fontWeight                         = "font-weight"
        case format                             = "format"
        case from                               = "from"
        case fr                                 = "fr"
        case fx                                 = "fx"
        case fy                                 = "fy"
        case g1                                 = "g1"
        case g2                                 = "g2"
        case glyphName                          = "glyph-name"
        case glyphOrientationHorizontal         = "glyph-orientation-horizontal"
        case glyphOrientationVertical           = "glyph-orientation-vertical"
        case glyphRef                           = "glyphRef"
        case gradientTransform                  = "gradientTransform"
        case gradientUnits                      = "gradientUnits"
        case hanging                            = "hanging"
        case height                             = "height"
        case href                               = "href"
        case hreflang                           = "hreflang"
        case horizAdvX                          = "horiz-adv-x"
        case horizOriginX                       = "horiz-origin-x"
        case id                                 = "id"
        case ideographic                        = "ideographic"
        case imageRendering                     = "image-rendering"
        case `in`                               = "in"
        case in2                                = "in2"
        case intercept                          = "intercept"
        case k                                  = "k"
        case k1                                 = "k1"
        case k2                                 = "k2"
        case k3                                 = "k3"
        case k4                                 = "k4"
        case kernelMatrix                       = "kernelMatrix"
        case kernelUnitLength                   = "kernelUnitLength"
        case kerning                            = "kerning"
        case keyPoints                          = "keyPoints"
        case keySplines                         = "keySplines"
        case keyTimes                           = "keyTimes"
        case lang                               = "lang"
        case lengthAdjust                       = "lengthAdjust"
        case letterSpacing                      = "letter-spacing"
        case lightingColor                      = "lighting-color"
        case limitingConeAngle                  = "limitingConeAngle"
        case local                              = "local"
        case markerEnd                          = "marker-end"
        case markerMid                          = "marker-mid"
        case markerStart                        = "marker-start"
        case markerHeight                       = "markerHeight"
        case markerUnits                        = "markerUnits"
        case markerWidth                        = "markerWidth"
        case mask                               = "mask"
        case maskContentUnits                   = "maskContentUnits"
        case maskUnits                          = "maskUnits"
        case mathematical                       = "mathematical"
        case max                                = "max"
        case media                              = "media"
        case method                             = "method"
        case min                                = "min"
        case mode                               = "mode"
        case name                               = "name"
        case numOctaves                         = "numOctaves"
        case offset                             = "offset"
        case opacity                            = "opacity"
        case `operator`                         = "operator"
        case order                              = "order"
        case orient                             = "orient"
        case orientation                        = "orientation"
        case origin                             = "origin"
        case overflow                           = "overflow"
        case overlinePosition                   = "overline-position"
        case overlineThickness                  = "overline-thickness"
        case panose1                            = "panose-1"
        case paintOrder                         = "paint-order"
        case path                               = "path"
        case pathLength                         = "pathLength"
        case patternContentUnits                = "patternContentUnits"
        case patternTransform                   = "patternTransform"
        case patternUnits                       = "patternUnits"
        case ping                               = "ping"
        case pointerEvents                      = "pointer-events"
        case points                             = "points"
        case pointsAtX                          = "pointsAtX"
        case pointsAtY                          = "pointsAtY"
        case pointsAtZ                          = "pointsAtZ"
        case preserveAlpha                      = "preserveAlpha"
        case preserveAspectRatio                = "preserveAspectRatio"
        case primitiveUnits                     = "primitiveUnits"
        case r                                  = "r"
        case radius                             = "radius"
        case referrerPolicy                     = "referrerPolicy"
        case refX                               = "refX"
        case refY                               = "refY"
        case rel                                = "rel"
        case renderingIntent                    = "rendering-intent"
        case repeatCount                        = "repeatCount"
        case repeatDur                          = "repeatDur"
        case requiredExtensions                 = "requiredExtensions"
        case requiredFeatures                   = "requiredFeatures"
        case restart                            = "restart"
        case result                             = "result"
        case rotate                             = "rotate"
        case rx                                 = "rx"
        case ry                                 = "ry"
        case scale                              = "scale"
        case seed                               = "seed"
        case shapeRendering                     = "shape-rendering"
        case slope                              = "slope"
        case spacing                            = "spacing"
        case specularConstant                   = "specularConstant"
        case specularExponent                   = "specularExponent"
        case speed                              = "speed"
        case spreadMethod                       = "spreadMethod"
        case startOffset                        = "startOffset"
        case stdDeviation                       = "stdDeviation"
        case stemh                              = "stemh"
        case stemv                              = "stemv"
        case stitchTiles                        = "stitchTiles"
        case stopColor                          = "stop-color"
        case stopOpacity                        = "stop-opacity"
        case strikethroughPosition              = "strikethrough-position"
        case strikethroughThickness             = "strikethrough-thickness"
        case string                             = "string"
        case stroke                             = "stroke"
        case strokeDasharray                    = "stroke-dasharray"
        case strokeDashoffset                   = "stroke-dashoffset"
        case strokeLinecap                      = "stroke-linecap"
        case strokeLinejoin                     = "stroke-linejoin"
        case strokeMiterlimit                   = "stroke-miterlimit"
        case strokeOpacity                      = "stroke-opacity"
        case strokeWidth                        = "stroke-width"
        case style                              = "style"
        case surfaceScale                       = "surfaceScale"
        case systemLanguage                     = "systemLanguage"
        case tabindex                           = "tabindex"
        case tableValues                        = "tableValues"
        case target                             = "target"
        case targetX                            = "targetX"
        case targetY                            = "targetY"
        case textAnchor                         = "text-anchor"
        case textDecoration                     = "text-decoration"
        case textRendering                      = "text-rendering"
        case textLength                         = "textLength"
        case to                                 = "to"
        case transform                          = "transform"
        case transformOrigin                    = "transform-origin"
        case type                               = "type"
        case u1                                 = "u1"
        case u2                                 = "u2"
        case underlinePosition                  = "underline-position"
        case underlineThickness                 = "underline-thickness"
        case unicode                            = "unicode"
        case unicodeBidi                        = "unicode-bidi"
        case unicodeRange                       = "unicode-range"
        case unitsPerEm                         = "units-per-em"
        case vAlphabetic                        = "v-alphabetic"
        case vHanging                           = "v-hanging"
        case vIdeographic                       = "v-ideographic"
        case vMathematical                      = "v-mathematical"
        case values                             = "values"
        case vectorEffect                       = "vector-effect"
        case version                            = "version"
        case vertAdvY                           = "vert-adv-y"
        case vertOriginX                        = "vert-origin-x"
        case vertOriginY                        = "vert-origin-y"
        case viewBox                            = "viewBox"
        case viewTarget                         = "viewTarget"
        case visibility                         = "visibility"
        case width                              = "width"
        case widths                             = "widths"
        case wordSpacing                        = "word-spacing"
        case writingMode                        = "writing-mode"
        case x                                  = "x"
        case xHeight                            = "x-height"
        case x1                                 = "x1"
        case x2                                 = "x2"
        case xChannelSelector                   = "xChannelSelector"
        case xlink_actuate                      = "xlink:actuate"
        case xlink_arcrole                      = "xlink:arcrole"
        case xlink_href                         = "xlink:href"
        case xlink_role                         = "xlink:role"
        case xlink_show                         = "xlink:show"
        case xlink_title                        = "xlink:title"
        case xlink_type                         = "xlink:type"
        case xml_base                           = "xml:base"
        case xml_lang                           = "xml:lang"
        case xml_space                          = "xml:space"
        case y                                  = "y"
        case y1                                 = "y1"
        case y2                                 = "y2"
        case yChannelSelector                   = "yChannelSelector"
        case z                                  = "z"
        case zoomAndPan                         = "zoomAndPan"

        @frozen public
        struct Factory
        {
            @inlinable internal init() {}

            @inlinable public var accentHeight:Attribute                    { .accentHeight }
            @inlinable public var accumulate:Attribute                      { .accumulate }
            @inlinable public var additive:Attribute                        { .additive }
            @inlinable public var alignmentBaseline:Attribute               { .alignmentBaseline }
            @inlinable public var alphabetic:Attribute                      { .alphabetic }
            @inlinable public var amplitude:Attribute                       { .amplitude }
            @inlinable public var arabicForm:Attribute                      { .arabicForm }
            @inlinable public var ascent:Attribute                          { .ascent }
            @inlinable public var attributeName:Attribute                   { .attributeName }
            @inlinable public var attributeType:Attribute                   { .attributeType }
            @inlinable public var azimuth:Attribute                         { .azimuth }
            @inlinable public var baseFrequency:Attribute                   { .baseFrequency }
            @inlinable public var baselineShift:Attribute                   { .baselineShift }
            @inlinable public var baseProfile:Attribute                     { .baseProfile }
            @inlinable public var bbox:Attribute                            { .bbox }
            @inlinable public var begin:Attribute                           { .begin }
            @inlinable public var bias:Attribute                            { .bias }
            @inlinable public var by:Attribute                              { .by }
            @inlinable public var calcMode:Attribute                        { .calcMode }
            @inlinable public var capHeight:Attribute                       { .capHeight }
            @inlinable public var `class`:Attribute                         { .class }
            @inlinable public var clip:Attribute                            { .clip }
            @inlinable public var clipPathUnits:Attribute                   { .clipPathUnits }
            @inlinable public var clipPath:Attribute                        { .clipPath }
            @inlinable public var clipRule:Attribute                        { .clipRule }
            @inlinable public var color:Attribute                           { .color }
            @inlinable public var colorInterpolation:Attribute              { .colorInterpolation }
            @inlinable public var colorInterpolationFilters:Attribute       { .colorInterpolationFilters }
            @inlinable public var colorProfile:Attribute                    { .colorProfile }
            @inlinable public var colorRendering:Attribute                  { .colorRendering }
            @inlinable public var contentScriptType:Attribute               { .contentScriptType }
            @inlinable public var contentStyleType:Attribute                { .contentStyleType }
            @inlinable public var crossorigin:Attribute                     { .crossorigin }
            @inlinable public var cursor:Attribute                          { .cursor }
            @inlinable public var cx:Attribute                              { .cx }
            @inlinable public var cy:Attribute                              { .cy }
            @inlinable public var d:Attribute                               { .d }
            @inlinable public var decelerate:Attribute                      { .decelerate }
            @inlinable public var descent:Attribute                         { .descent }
            @inlinable public var diffuseConstant:Attribute                 { .diffuseConstant }
            @inlinable public var direction:Attribute                       { .direction }
            @inlinable public var display:Attribute                         { .display }
            @inlinable public var divisor:Attribute                         { .divisor }
            @inlinable public var dominantBaseline:Attribute                { .dominantBaseline }
            @inlinable public var dur:Attribute                             { .dur }
            @inlinable public var dx:Attribute                              { .dx }
            @inlinable public var dy:Attribute                              { .dy }
            @inlinable public var edgeMode:Attribute                        { .edgeMode }
            @inlinable public var elevation:Attribute                       { .elevation }
            @inlinable public var enableBackground:Attribute                { .enableBackground }
            @inlinable public var end:Attribute                             { .end }
            @inlinable public var exponent:Attribute                        { .exponent }
            @inlinable public var fill:Attribute                            { .fill }
            @inlinable public var fillOpacity:Attribute                     { .fillOpacity }
            @inlinable public var fillRule:Attribute                        { .fillRule }
            @inlinable public var filter:Attribute                          { .filter }
            @inlinable public var filterRes:Attribute                       { .filterRes }
            @inlinable public var filterUnits:Attribute                     { .filterUnits }
            @inlinable public var floodColor:Attribute                      { .floodColor }
            @inlinable public var floodOpacity:Attribute                    { .floodOpacity }
            @inlinable public var fontFamily:Attribute                      { .fontFamily }
            @inlinable public var fontSize:Attribute                        { .fontSize }
            @inlinable public var fontSizeAdjust:Attribute                  { .fontSizeAdjust }
            @inlinable public var fontStretch:Attribute                     { .fontStretch }
            @inlinable public var fontStyle:Attribute                       { .fontStyle }
            @inlinable public var fontVariant:Attribute                     { .fontVariant }
            @inlinable public var fontWeight:Attribute                      { .fontWeight }
            @inlinable public var format:Attribute                          { .format }
            @inlinable public var from:Attribute                            { .from }
            @inlinable public var fr:Attribute                              { .fr }
            @inlinable public var fx:Attribute                              { .fx }
            @inlinable public var fy:Attribute                              { .fy }
            @inlinable public var g1:Attribute                              { .g1 }
            @inlinable public var g2:Attribute                              { .g2 }
            @inlinable public var glyphName:Attribute                       { .glyphName }
            @inlinable public var glyphOrientationHorizontal:Attribute      { .glyphOrientationHorizontal }
            @inlinable public var glyphOrientationVertical:Attribute        { .glyphOrientationVertical }
            @inlinable public var glyphRef:Attribute                        { .glyphRef }
            @inlinable public var gradientTransform:Attribute               { .gradientTransform }
            @inlinable public var gradientUnits:Attribute                   { .gradientUnits }
            @inlinable public var hanging:Attribute                         { .hanging }
            @inlinable public var height:Attribute                          { .height }
            @inlinable public var href:Attribute                            { .href }
            @inlinable public var hreflang:Attribute                        { .hreflang }
            @inlinable public var horizAdvX:Attribute                       { .horizAdvX }
            @inlinable public var horizOriginX:Attribute                    { .horizOriginX }
            @inlinable public var id:Attribute                              { .id }
            @inlinable public var ideographic:Attribute                     { .ideographic }
            @inlinable public var imageRendering:Attribute                  { .imageRendering }
            @inlinable public var `in`:Attribute                            { .in }
            @inlinable public var in2:Attribute                             { .in2 }
            @inlinable public var intercept:Attribute                       { .intercept }
            @inlinable public var k:Attribute                               { .k }
            @inlinable public var k1:Attribute                              { .k1 }
            @inlinable public var k2:Attribute                              { .k2 }
            @inlinable public var k3:Attribute                              { .k3 }
            @inlinable public var k4:Attribute                              { .k4 }
            @inlinable public var kernelMatrix:Attribute                    { .kernelMatrix }
            @inlinable public var kernelUnitLength:Attribute                { .kernelUnitLength }
            @inlinable public var kerning:Attribute                         { .kerning }
            @inlinable public var keyPoints:Attribute                       { .keyPoints }
            @inlinable public var keySplines:Attribute                      { .keySplines }
            @inlinable public var keyTimes:Attribute                        { .keyTimes }
            @inlinable public var lang:Attribute                            { .lang }
            @inlinable public var lengthAdjust:Attribute                    { .lengthAdjust }
            @inlinable public var letterSpacing:Attribute                   { .letterSpacing }
            @inlinable public var lightingColor:Attribute                   { .lightingColor }
            @inlinable public var limitingConeAngle:Attribute               { .limitingConeAngle }
            @inlinable public var local:Attribute                           { .local }
            @inlinable public var markerEnd:Attribute                       { .markerEnd }
            @inlinable public var markerMid:Attribute                       { .markerMid }
            @inlinable public var markerStart:Attribute                     { .markerStart }
            @inlinable public var markerHeight:Attribute                    { .markerHeight }
            @inlinable public var markerUnits:Attribute                     { .markerUnits }
            @inlinable public var markerWidth:Attribute                     { .markerWidth }
            @inlinable public var mask:Attribute                            { .mask }
            @inlinable public var maskContentUnits:Attribute                { .maskContentUnits }
            @inlinable public var maskUnits:Attribute                       { .maskUnits }
            @inlinable public var mathematical:Attribute                    { .mathematical }
            @inlinable public var max:Attribute                             { .max }
            @inlinable public var media:Attribute                           { .media }
            @inlinable public var method:Attribute                          { .method }
            @inlinable public var min:Attribute                             { .min }
            @inlinable public var mode:Attribute                            { .mode }
            @inlinable public var name:Attribute                            { .name }
            @inlinable public var numOctaves:Attribute                      { .numOctaves }
            @inlinable public var offset:Attribute                          { .offset }
            @inlinable public var opacity:Attribute                         { .opacity }
            @inlinable public var `operator`:Attribute                      { .operator }
            @inlinable public var order:Attribute                           { .order }
            @inlinable public var orient:Attribute                          { .orient }
            @inlinable public var orientation:Attribute                     { .orientation }
            @inlinable public var origin:Attribute                          { .origin }
            @inlinable public var overflow:Attribute                        { .overflow }
            @inlinable public var overlinePosition:Attribute                { .overlinePosition }
            @inlinable public var overlineThickness:Attribute               { .overlineThickness }
            @inlinable public var panose1:Attribute                         { .panose1 }
            @inlinable public var paintOrder:Attribute                      { .paintOrder }
            @inlinable public var path:Attribute                            { .path }
            @inlinable public var pathLength:Attribute                      { .pathLength }
            @inlinable public var patternContentUnits:Attribute             { .patternContentUnits }
            @inlinable public var patternTransform:Attribute                { .patternTransform }
            @inlinable public var patternUnits:Attribute                    { .patternUnits }
            @inlinable public var ping:Attribute                            { .ping }
            @inlinable public var pointerEvents:Attribute                   { .pointerEvents }
            @inlinable public var points:Attribute                          { .points }
            @inlinable public var pointsAtX:Attribute                       { .pointsAtX }
            @inlinable public var pointsAtY:Attribute                       { .pointsAtY }
            @inlinable public var pointsAtZ:Attribute                       { .pointsAtZ }
            @inlinable public var preserveAlpha:Attribute                   { .preserveAlpha }
            @inlinable public var preserveAspectRatio:Attribute             { .preserveAspectRatio }
            @inlinable public var primitiveUnits:Attribute                  { .primitiveUnits }
            @inlinable public var r:Attribute                               { .r }
            @inlinable public var radius:Attribute                          { .radius }
            @inlinable public var referrerPolicy:Attribute                  { .referrerPolicy }
            @inlinable public var refX:Attribute                            { .refX }
            @inlinable public var refY:Attribute                            { .refY }
            @inlinable public var rel:Attribute                             { .rel }
            @inlinable public var renderingIntent:Attribute                 { .renderingIntent }
            @inlinable public var repeatCount:Attribute                     { .repeatCount }
            @inlinable public var repeatDur:Attribute                       { .repeatDur }
            @inlinable public var requiredExtensions:Attribute              { .requiredExtensions }
            @inlinable public var requiredFeatures:Attribute                { .requiredFeatures }
            @inlinable public var restart:Attribute                         { .restart }
            @inlinable public var result:Attribute                          { .result }
            @inlinable public var rotate:Attribute                          { .rotate }
            @inlinable public var rx:Attribute                              { .rx }
            @inlinable public var ry:Attribute                              { .ry }
            @inlinable public var scale:Attribute                           { .scale }
            @inlinable public var seed:Attribute                            { .seed }
            @inlinable public var shapeRendering:Attribute                  { .shapeRendering }
            @inlinable public var slope:Attribute                           { .slope }
            @inlinable public var spacing:Attribute                         { .spacing }
            @inlinable public var specularConstant:Attribute                { .specularConstant }
            @inlinable public var specularExponent:Attribute                { .specularExponent }
            @inlinable public var speed:Attribute                           { .speed }
            @inlinable public var spreadMethod:Attribute                    { .spreadMethod }
            @inlinable public var startOffset:Attribute                     { .startOffset }
            @inlinable public var stdDeviation:Attribute                    { .stdDeviation }
            @inlinable public var stemh:Attribute                           { .stemh }
            @inlinable public var stemv:Attribute                           { .stemv }
            @inlinable public var stitchTiles:Attribute                     { .stitchTiles }
            @inlinable public var stopColor:Attribute                       { .stopColor }
            @inlinable public var stopOpacity:Attribute                     { .stopOpacity }
            @inlinable public var strikethroughPosition:Attribute           { .strikethroughPosition }
            @inlinable public var strikethroughThickness:Attribute          { .strikethroughThickness }
            @inlinable public var string:Attribute                          { .string }
            @inlinable public var stroke:Attribute                          { .stroke }
            @inlinable public var strokeDasharray:Attribute                 { .strokeDasharray }
            @inlinable public var strokeDashoffset:Attribute                { .strokeDashoffset }
            @inlinable public var strokeLinecap:Attribute                   { .strokeLinecap }
            @inlinable public var strokeLinejoin:Attribute                  { .strokeLinejoin }
            @inlinable public var strokeMiterlimit:Attribute                { .strokeMiterlimit }
            @inlinable public var strokeOpacity:Attribute                   { .strokeOpacity }
            @inlinable public var strokeWidth:Attribute                     { .strokeWidth }
            @inlinable public var style:Attribute                           { .style }
            @inlinable public var surfaceScale:Attribute                    { .surfaceScale }
            @inlinable public var systemLanguage:Attribute                  { .systemLanguage }
            @inlinable public var tabindex:Attribute                        { .tabindex }
            @inlinable public var tableValues:Attribute                     { .tableValues }
            @inlinable public var target:Attribute                          { .target }
            @inlinable public var targetX:Attribute                         { .targetX }
            @inlinable public var targetY:Attribute                         { .targetY }
            @inlinable public var textAnchor:Attribute                      { .textAnchor }
            @inlinable public var textDecoration:Attribute                  { .textDecoration }
            @inlinable public var textRendering:Attribute                   { .textRendering }
            @inlinable public var textLength:Attribute                      { .textLength }
            @inlinable public var to:Attribute                              { .to }
            @inlinable public var transform:Attribute                       { .transform }
            @inlinable public var transformOrigin:Attribute                 { .transformOrigin }
            @inlinable public var type:Attribute                            { .type }
            @inlinable public var u1:Attribute                              { .u1 }
            @inlinable public var u2:Attribute                              { .u2 }
            @inlinable public var underlinePosition:Attribute               { .underlinePosition }
            @inlinable public var underlineThickness:Attribute              { .underlineThickness }
            @inlinable public var unicode:Attribute                         { .unicode }
            @inlinable public var unicodeBidi:Attribute                     { .unicodeBidi }
            @inlinable public var unicodeRange:Attribute                    { .unicodeRange }
            @inlinable public var unitsPerEm:Attribute                      { .unitsPerEm }
            @inlinable public var vAlphabetic:Attribute                     { .vAlphabetic }
            @inlinable public var vHanging:Attribute                        { .vHanging }
            @inlinable public var vIdeographic:Attribute                    { .vIdeographic }
            @inlinable public var vMathematical:Attribute                   { .vMathematical }
            @inlinable public var values:Attribute                          { .values }
            @inlinable public var vectorEffect:Attribute                    { .vectorEffect }
            @inlinable public var version:Attribute                         { .version }
            @inlinable public var vertAdvY:Attribute                        { .vertAdvY }
            @inlinable public var vertOriginX:Attribute                     { .vertOriginX }
            @inlinable public var vertOriginY:Attribute                     { .vertOriginY }
            @inlinable public var viewBox:Attribute                         { .viewBox }
            @inlinable public var viewTarget:Attribute                      { .viewTarget }
            @inlinable public var visibility:Attribute                      { .visibility }
            @inlinable public var width:Attribute                           { .width }
            @inlinable public var widths:Attribute                          { .widths }
            @inlinable public var wordSpacing:Attribute                     { .wordSpacing }
            @inlinable public var writingMode:Attribute                     { .writingMode }
            @inlinable public var x:Attribute                               { .x }
            @inlinable public var xHeight:Attribute                         { .xHeight }
            @inlinable public var x1:Attribute                              { .x1 }
            @inlinable public var x2:Attribute                              { .x2 }
            @inlinable public var xChannelSelector:Attribute                { .xChannelSelector }
            @inlinable public var xlink_actuate:Attribute                   { .xlink_actuate }
            @inlinable public var xlink_arcrole:Attribute                   { .xlink_arcrole }
            @inlinable public var xlink_href:Attribute                      { .xlink_href }
            @inlinable public var xlink_role:Attribute                      { .xlink_role }
            @inlinable public var xlink_show:Attribute                      { .xlink_show }
            @inlinable public var xlink_title:Attribute                     { .xlink_title }
            @inlinable public var xlink_type:Attribute                      { .xlink_type }
            @inlinable public var xml_base:Attribute                        { .xml_base }
            @inlinable public var xml_lang:Attribute                        { .xml_lang }
            @inlinable public var xml_space:Attribute                       { .xml_space }
            @inlinable public var y:Attribute                               { .y }
            @inlinable public var y1:Attribute                              { .y1 }
            @inlinable public var y2:Attribute                              { .y2 }
            @inlinable public var yChannelSelector:Attribute                { .yChannelSelector }
            @inlinable public var z:Attribute                               { .z }
            @inlinable public var zoomAndPan:Attribute                      { .zoomAndPan }
        }
    }
}
