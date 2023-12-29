import DynamicLookupMacros

extension SVG
{
    @GenerateDynamicMemberFactory
    @frozen public
    enum Attribute:String, DOM.Attribute, Equatable, Hashable, Sendable
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
    }
}
