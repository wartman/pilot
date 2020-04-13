Dynamic CSS
-----------
When compiling CSS, we do some simple checks.

If the CSS does not have any interpolations OR if all interpolations are static, then we return a VStaticCss. This will be immediately rendered and added to the style sheet when the app starts (or will be compiled to the external stylesheet).

If the CSS DOES have interpolated vales, we create a VDynamicCss. This css generates a unique id based on the interpolated values and, if the values (and thus the ID) change, a new CSS definition will be generated and added to the DOM (or whatever implementation we're using). Note that if the generated name is the same as one that already exists, no new style will be added.

The implementation will look something like this:

```haxe

// We're returning an enum something like this:
enum VStyle {
  VStaticCss(name:String, css:String);
  VDynamicCss(name:String, factory:()->String);
}

// No interpolation: returns static CSS.
var foo = css('width: 500px');
// The return value will be something like:
// VStaticCss('p_myclass_21', '.p_myclass_21 { width: 500px; }')

// Interpolation: returns dynamic CSS.
var width = '20px';
var bar = css('width: ${width}');
// The return value will be something like:
// VStaticCss(
//   'p_myclass_26_${CssTools.cssClassNameEscape(width)}', 
//   () -> '.p_myclass_26_${CssTools.cssClassNameEscape(width)} { width: ${width}; }'
// );

```

This will allow us a lot more flexibility in writing styles.

> Note: This will need to continue working with the current system, where
> it's possible to use Styles in places that require constant values
> (like in enum abstracts). This will take a bit more thought, but
> should be doable.
