extension SVG
{
    @frozen public
    enum Attribute:String, Equatable, Hashable, Sendable
    {
        case accent_height = "accent-height"
        case accumulate
        case additive
        case alignment_baseline = "alignment-baseline"
        case alphabetic
        case amplitude
        case arabic_form = "arabic-form"
        case ascent
        case attributeName
        case attributeType
        case azimuth
        case baseFrequency
        case baseline_shift = "baseline-shift"
        case baseProfile
        case bbox
        case begin
        case bias
        case by
        case calcMode
        case cap_height
        case `class`
        case clip
        case clipPathUnits
        case clip_path
        case clip_rule
        case color
        case color_interpolation = "color-interpolation"
        case color_interpolation_filters = "color-interpolation-filters"
        case color_profile = "color-profile"
        case color_rendering = "color-rendering"
        case contentScriptType
        case contentStyleType
        case crossorigin
        case cursor
        case cx
        case cy
        case d
        case decelerate
        case descent
        case diffuseConstant
        case direction
        case display
        case divisor
        case dominant_baseline = "dominant-baseline"
        case dur
        case dx
        case dy
        case edgeMode
        case elevation
        case enable_background
        case end
        case exponent
        case fill
        case fill_opacity = "fill-opacity"
        case fill_rule = "fill-rule"
        case filter
        case filterRes
        case filterUnits
        case flood_color
        case flood_opacity
        case font_family
        case font_size = "font-size"
        case font_size_adjust = "font-size-adjust"
        case font_stretch = "font-stretch"
        case font_style = "font-style"
        case font_variant = "font-variant"
        case font_weight = "font-weight"
        case format
        case from
        case fr
        case fx
        case fy
        case g1
        case g2
        case glyph_name = "glyph-name"
        case glyph_orientation_horizontal = "glyph-orientation-horizontal"
        case glyph_orientation_vertical = "glyph-orientation-vertical"
        case glyphRef
        case gradientTransform
        case gradientUnits
        case hanging
        case height
        case href
        case hreflang
        case horiz_adv_x = "horiz-adv-x"
        case horiz_origin_x = "horiz-origin-x"
        case id
        case ideographic
        case image_rendering = "image-rendering"
        case `in`
        case in2
        case intercept
        case k
        case k1
        case k2
        case k3
        case k4
        case kernelMatrix
        case kernelUnitLength
        case kerning
        case keyPoints
        case keySplines
        case keyTimes
        case lang
        case lengthAdjust
        case letter_spacing = "letter-spacing"
        case lighting_color = "lighting-color"
        case limitingConeAngle
        case local
        case marker_end = "marker-end"
        case marker_mid = "marker-mid"
        case marker_start = "marker-start"
        case markerHeight
        case markerUnits
        case markerWidth
        case mask
        case maskContentUnits
        case maskUnits
        case mathematical
        case max
        case media
        case method
        case min
        case mode
        case name
        case numOctaves
        case offset
        case opacity
        case `operator`
        case order
        case orient
        case orientation
        case origin
        case overflow
        case overline_position = "overline-position"
        case overline_thickness = "overline-thickness"
        case panose_1 = "panose-1"
        case paint_order = "paint-order"
        case path
        case pathLength
        case patternContentUnits
        case patternTransform
        case patternUnits
        case ping
        case pointer_events = "pointer-events"
        case points
        case pointsAtX
        case pointsAtY
        case pointsAtZ
        case preserveAlpha
        case preserveAspectRatio
        case primitiveUnits
        case r
        case radius
        case referrerPolicy
        case refX
        case refY
        case rel
        case rendering_intent = "rendering-intent"
        case repeatCount
        case repeatDur
        case requiredExtensions
        case requiredFeatures
        case restart
        case result
        case rotate
        case rx
        case ry
        case scale
        case seed
        case shape_rendering = "shape-rendering"
        case slope
        case spacing
        case specularConstant
        case specularExponent
        case speed
        case spreadMethod
        case startOffset
        case stdDeviation
        case stemh
        case stemv
        case stitchTiles
        case stop_color = "stop-color"
        case stop_opacity = "stop-opacity"
        case strikethrough_position = "strikethrough-position"
        case strikethrough_thickness = "strikethrough-thickness"
        case string
        case stroke
        case stroke_dasharray = "stroke-dasharray"
        case stroke_dashoffset = "stroke-dashoffset"
        case stroke_linecap = "stroke-linecap"
        case stroke_linejoin = "stroke-linejoin"
        case stroke_miterlimit = "stroke-miterlimit"
        case stroke_opacity = "stroke-opacity"
        case stroke_width = "stroke-width"
        case style
        case surfaceScale
        case systemLanguage
        case tabindex
        case tableValues
        case target
        case targetX
        case targetY
        case text_anchor = "text-anchor"
        case text_decoration = "text-decoration"
        case text_rendering = "text-rendering"
        case textLength
        case to
        case transform
        case transform_origin = "transform-origin"
        case type
        case u1
        case u2
        case underline_position = "underline-position"
        case underline_thickness = "underline-thickness"
        case unicode
        case unicode_bidi = "unicode-bidi"
        case unicode_range = "unicode-range"
        case units_per_em = "units-per-em"
        case v_alphabetic = "v-alphabetic"
        case v_hanging = "v-hanging"
        case v_ideographic = "v-ideographic"
        case v_mathematical = "v-mathematical"
        case values
        case vector_effect = "vector-effect"
        case version
        case vert_adv_y = "vert-adv-y"
        case vert_origin_x = "vert-origin-x"
        case vert_origin_y = "vert-origin-y"
        case viewBox
        case viewTarget
        case visibility
        case width
        case widths
        case word_spacing = "word-spacing"
        case writing_mode = "writing-mode"
        case x = "x"
        case x_height = "x-height"
        case x1
        case x2
        case xChannelSelector
        case xlink_actuate = "xlink:actuate"
        case xlink_arcrole = "xlink:arcrole"
        case xlink_href = "xlink:href"
        case xlink_role = "xlink:role"
        case xlink_show = "xlink:show"
        case xlink_title = "xlink:title"
        case xlink_type = "xlink:type"
        case xml_base = "xml:base"
        case xml_lang = "xml:lang"
        case xml_space = "xml:space"
        case y
        case y1
        case y2
        case yChannelSelector
        case z
        case zoomAndPan

        @frozen public
        struct Factory
        {
            @inlinable internal init() {}

            @inlinable public var accent_height:Attribute                   { .accent_height }
            @inlinable public var accumulate:Attribute                      { .accumulate }
            @inlinable public var additive:Attribute                        { .additive }
            @inlinable public var alignment_baseline:Attribute              { .alignment_baseline }
            @inlinable public var alphabetic:Attribute                      { .alphabetic }
            @inlinable public var amplitude:Attribute                       { .amplitude }
            @inlinable public var arabic_form:Attribute                     { .arabic_form }
            @inlinable public var ascent:Attribute                          { .ascent }
            @inlinable public var attributeName:Attribute                   { .attributeName }
            @inlinable public var attributeType:Attribute                   { .attributeType }
            @inlinable public var azimuth:Attribute                         { .azimuth }
            @inlinable public var baseFrequency:Attribute                   { .baseFrequency }
            @inlinable public var baseline_shift:Attribute                  { .baseline_shift }
            @inlinable public var baseProfile:Attribute                     { .baseProfile }
            @inlinable public var bbox:Attribute                            { .bbox }
            @inlinable public var begin:Attribute                           { .begin }
            @inlinable public var bias:Attribute                            { .bias }
            @inlinable public var by:Attribute                              { .by }
            @inlinable public var calcMode:Attribute                        { .calcMode }
            @inlinable public var cap_height:Attribute                      { .cap_height }
            @inlinable public var `class`:Attribute                         { .class }
            @inlinable public var clip:Attribute                            { .clip }
            @inlinable public var clipPathUnits:Attribute                   { .clipPathUnits }
            @inlinable public var clip_path:Attribute                       { .clip_path }
            @inlinable public var clip_rule:Attribute                       { .clip_rule }
            @inlinable public var color:Attribute                           { .color }
            @inlinable public var color_interpolation:Attribute             { .color_interpolation }
            @inlinable public var color_interpolation_filters:Attribute     { .color_interpolation_filters }
            @inlinable public var color_profile:Attribute                   { .color_profile }
            @inlinable public var color_rendering:Attribute                 { .color_rendering }
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
            @inlinable public var dominant_baseline:Attribute               { .dominant_baseline }
            @inlinable public var dur:Attribute                             { .dur }
            @inlinable public var dx:Attribute                              { .dx }
            @inlinable public var dy:Attribute                              { .dy }
            @inlinable public var edgeMode:Attribute                        { .edgeMode }
            @inlinable public var elevation:Attribute                       { .elevation }
            @inlinable public var enable_background:Attribute               { .enable_background }
            @inlinable public var end:Attribute                             { .end }
            @inlinable public var exponent:Attribute                        { .exponent }
            @inlinable public var fill:Attribute                            { .fill }
            @inlinable public var fill_opacity:Attribute                    { .fill_opacity }
            @inlinable public var fill_rule:Attribute                       { .fill_rule }
            @inlinable public var filter:Attribute                          { .filter }
            @inlinable public var filterRes:Attribute                       { .filterRes }
            @inlinable public var filterUnits:Attribute                     { .filterUnits }
            @inlinable public var flood_color:Attribute                     { .flood_color }
            @inlinable public var flood_opacity:Attribute                   { .flood_opacity }
            @inlinable public var font_family:Attribute                     { .font_family }
            @inlinable public var font_size:Attribute                       { .font_size }
            @inlinable public var font_size_adjust:Attribute                { .font_size_adjust }
            @inlinable public var font_stretch:Attribute                    { .font_stretch }
            @inlinable public var font_style:Attribute                      { .font_style }
            @inlinable public var font_variant:Attribute                    { .font_variant }
            @inlinable public var font_weight:Attribute                     { .font_weight }
            @inlinable public var format:Attribute                          { .format }
            @inlinable public var from:Attribute                            { .from }
            @inlinable public var fr:Attribute                              { .fr }
            @inlinable public var fx:Attribute                              { .fx }
            @inlinable public var fy:Attribute                              { .fy }
            @inlinable public var g1:Attribute                              { .g1 }
            @inlinable public var g2:Attribute                              { .g2 }
            @inlinable public var glyph_name:Attribute                      { .glyph_name }
            @inlinable public var glyph_orientation_horizontal:Attribute    { .glyph_orientation_horizontal }
            @inlinable public var glyph_orientation_vertical:Attribute      { .glyph_orientation_vertical }
            @inlinable public var glyphRef:Attribute                        { .glyphRef }
            @inlinable public var gradientTransform:Attribute               { .gradientTransform }
            @inlinable public var gradientUnits:Attribute                   { .gradientUnits }
            @inlinable public var hanging:Attribute                         { .hanging }
            @inlinable public var height:Attribute                          { .height }
            @inlinable public var href:Attribute                            { .href }
            @inlinable public var hreflang:Attribute                        { .hreflang }
            @inlinable public var horiz_adv_x:Attribute                     { .horiz_adv_x }
            @inlinable public var horiz_origin_x:Attribute                  { .horiz_origin_x }
            @inlinable public var id:Attribute                              { .id }
            @inlinable public var ideographic:Attribute                     { .ideographic }
            @inlinable public var image_rendering:Attribute                 { .image_rendering }
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
            @inlinable public var letter_spacing:Attribute                  { .letter_spacing }
            @inlinable public var lighting_color:Attribute                  { .lighting_color }
            @inlinable public var limitingConeAngle:Attribute               { .limitingConeAngle }
            @inlinable public var local:Attribute                           { .local }
            @inlinable public var marker_end:Attribute                      { .marker_end }
            @inlinable public var marker_mid:Attribute                      { .marker_mid }
            @inlinable public var marker_start:Attribute                    { .marker_start }
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
            @inlinable public var overline_position:Attribute               { .overline_position }
            @inlinable public var overline_thickness:Attribute              { .overline_thickness }
            @inlinable public var panose_1:Attribute                        { .panose_1 }
            @inlinable public var paint_order:Attribute                     { .paint_order }
            @inlinable public var path:Attribute                            { .path }
            @inlinable public var pathLength:Attribute                      { .pathLength }
            @inlinable public var patternContentUnits:Attribute             { .patternContentUnits }
            @inlinable public var patternTransform:Attribute                { .patternTransform }
            @inlinable public var patternUnits:Attribute                    { .patternUnits }
            @inlinable public var ping:Attribute                            { .ping }
            @inlinable public var pointer_events:Attribute                  { .pointer_events }
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
            @inlinable public var rendering_intent:Attribute                { .rendering_intent }
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
            @inlinable public var shape_rendering:Attribute                 { .shape_rendering }
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
            @inlinable public var stop_color:Attribute                      { .stop_color }
            @inlinable public var stop_opacity:Attribute                    { .stop_opacity }
            @inlinable public var strikethrough_position:Attribute          { .strikethrough_position }
            @inlinable public var strikethrough_thickness:Attribute         { .strikethrough_thickness }
            @inlinable public var string:Attribute                          { .string }
            @inlinable public var stroke:Attribute                          { .stroke }
            @inlinable public var stroke_dasharray:Attribute                { .stroke_dasharray }
            @inlinable public var stroke_dashoffset:Attribute               { .stroke_dashoffset }
            @inlinable public var stroke_linecap:Attribute                  { .stroke_linecap }
            @inlinable public var stroke_linejoin:Attribute                 { .stroke_linejoin }
            @inlinable public var stroke_miterlimit:Attribute               { .stroke_miterlimit }
            @inlinable public var stroke_opacity:Attribute                  { .stroke_opacity }
            @inlinable public var stroke_width:Attribute                    { .stroke_width }
            @inlinable public var style:Attribute                           { .style }
            @inlinable public var surfaceScale:Attribute                    { .surfaceScale }
            @inlinable public var systemLanguage:Attribute                  { .systemLanguage }
            @inlinable public var tabindex:Attribute                        { .tabindex }
            @inlinable public var tableValues:Attribute                     { .tableValues }
            @inlinable public var target:Attribute                          { .target }
            @inlinable public var targetX:Attribute                         { .targetX }
            @inlinable public var targetY:Attribute                         { .targetY }
            @inlinable public var text_anchor:Attribute                     { .text_anchor }
            @inlinable public var text_decoration:Attribute                 { .text_decoration }
            @inlinable public var text_rendering:Attribute                  { .text_rendering }
            @inlinable public var textLength:Attribute                      { .textLength }
            @inlinable public var to:Attribute                              { .to }
            @inlinable public var transform:Attribute                       { .transform }
            @inlinable public var transform_origin:Attribute                { .transform_origin }
            @inlinable public var type:Attribute                            { .type }
            @inlinable public var u1:Attribute                              { .u1 }
            @inlinable public var u2:Attribute                              { .u2 }
            @inlinable public var underline_position:Attribute              { .underline_position }
            @inlinable public var underline_thickness:Attribute             { .underline_thickness }
            @inlinable public var unicode:Attribute                         { .unicode }
            @inlinable public var unicode_bidi:Attribute                    { .unicode_bidi }
            @inlinable public var unicode_range:Attribute                   { .unicode_range }
            @inlinable public var units_per_em:Attribute                    { .units_per_em }
            @inlinable public var v_alphabetic:Attribute                    { .v_alphabetic }
            @inlinable public var v_hanging:Attribute                       { .v_hanging }
            @inlinable public var v_ideographic:Attribute                   { .v_ideographic }
            @inlinable public var v_mathematical:Attribute                  { .v_mathematical }
            @inlinable public var values:Attribute                          { .values }
            @inlinable public var vector_effect:Attribute                   { .vector_effect }
            @inlinable public var version:Attribute                         { .version }
            @inlinable public var vert_adv_y:Attribute                      { .vert_adv_y }
            @inlinable public var vert_origin_x:Attribute                   { .vert_origin_x }
            @inlinable public var vert_origin_y:Attribute                   { .vert_origin_y }
            @inlinable public var viewBox:Attribute                         { .viewBox }
            @inlinable public var viewTarget:Attribute                      { .viewTarget }
            @inlinable public var visibility:Attribute                      { .visibility }
            @inlinable public var width:Attribute                           { .width }
            @inlinable public var widths:Attribute                          { .widths }
            @inlinable public var word_spacing:Attribute                    { .word_spacing }
            @inlinable public var writing_mode:Attribute                    { .writing_mode }
            @inlinable public var x:Attribute                               { .x }
            @inlinable public var x_height:Attribute                        { .x_height }
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
