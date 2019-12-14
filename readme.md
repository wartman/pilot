Pilot
=====

A batteries-included UI framework.

> Under heavy reworking.

Usage
-----

Pilot handles CSS, HTML and VNode diffing for both browsers and servers, allowing you to use almost the same code across many different targets. Additionally, pilot is quite small: most of the complicated stuff is handled during compiling. 

That's the dream, anyway.

```haxe

import pilot.Component;

class App extends Component {

  @:attribute(mutable = true) var shouldShowExample:Bool = false;
  @:style(global = true) var root = '
    body {
      background: black;
      color: white;
    }
  ';

  override function render() return html(<div>
    <if {shouldShowExample}>
      <Example foo="Some Foo" />
    <else>
      Nothing to show here!
    </if>
    <button onClick={_ -> shouldShowExample = !shouldShowExample}>
      Toggle
    </button>
  </div>);

}

class Example extends Component {

  @:attribute var foo:String;

  override function render() return html(<div class@style={
    height: 20px;
    line-height: 20px;
  }>
    <h1>${foo}</h1>
  </div>);

}

```

Examples
--------

- [TodoMVC](https://github.com/wartman/pilot.todo)

Lifecycle
---------

Components can have methods marked with lifecycle meta (`@:init`, `@:effect`, `@:dispose` or `@:guard`).

`@:init` (or `@:initialize` if you're feeling verbose) will be run _once_ when the Component is constructed.

`@:effect` will be run _every time_ the Component has been rendered and is mounted in the DOM. This is where you'll want to handle things like checking if the user clicked off the component's node (use `getRealNode()` to access the mounted DOM node). You can determine if effects should run with the `guard` option, which might look something like this: `@:effect(guard = someAttribute != null)`.

`@:dispose` will be run _once_, after the Component is removed from the DOM. This is where you should handle any cleanup your component needs.

> Note: `@:guard` is currently undergoing some changes as I figure out the best API for it.

Markup Attribute Macros
-----------------------

Currently there are only two attribute macros: `@style` and `@html`. There may be more in the future (along with the ability to define your own). Attribute macros may be appended to any attribute name and will handle the value at compile time. 

Use `@style` to parse styles. Generally used with `class`, although it can be used for any attribute that expects a `pilot.Style` as well.

```haxe
Pilot.html(<div class@style={
  width: 200px;
  height: 50px;
}>Hello world</div>);
```

Use `@html` to parse markup. This might be handy in situations where you have more than one slot for content.

```haxe
var title = 'bar';
Pilot.html(<Alert
  title@html={<h2>{title}</h2>}
>
  <p>Some warning about a thing.</p>
</Alert>);
```

There are also two special attributes (for now) you can use: `@ref` and `@key`:

```haxe
Pilot.html(
  <div
    @ref={node -> {
      // Allows access to the real DOM (if a JS target) or to Pilot's
      // very limited DOM implementation (for Sys targets). 
      trace(node);
    }}
    @key="A unique key!"
  >foo</div>
);

```

CSS Generation Options
----------------------

Pilot can export CSS to an external file, embed it into the javascript output, or a combination of both.

For example, the following `hxml` will embed all the css into `assets/app.js`, meaning you'll only need `app.js`:

```hxml
-lib pilot
-main MyApp
-js assets/app.js
```

To export css, simply define `-D pilot-css-output=PATH/TO/YOUR/css.css` in your `hxml` file. This will be exported relative to your current compile target. For example, the following `hxml` file will export `assets/app.js` and `assets/app.css`:

```hxml
-lib pilot
-main MyApp
-D pilot-css-output=app.css
-js assets/app.js
```

Things get slightly more complicated if you're exporting to more than one target. You should only need to generate your CSS once, so you can set `-D pilot-css-skip` to tell pilot that it doesn't need to generate CSS for a given target:

```hxml
-lib pilot
-main MyApp

--each

-D pilot-css-output=app.css
-php dist

--next

-D pilot-css-skip
-js dist/assets/app.js
```

Generally, if you're creating an isomorphic app you should generate CSS for the SERVER target (in this case, `php`) and skip the client (or `js`) target. The reason for this is that Pilot allows you to force CSS embedding, meaning you can include any CSS the server target might miss.

For example, say we have a Modal component. This might never get used in a PHP or Node target, as we might never display it. To get around this, you can do the following:

```haxe
import pilot.Component;

class ModalOrSomething extends Component {

  // Mark @:style meta for embedding:
  @:style(embed = true) var foo = '
    background: blue;
  ';

  override function render() return html(
    <div class={foo}>
      // We can also use `@style-embed` in our markup to get the same result:
      <div class@style-embed={
        background: white;
      }>Stuff</div>
    </div>
  );

}
```

Other Options
-------------

Pilot is heavily based on/inspired by [Coconut](https://github.com/MVCoconut) and [Cix](https://github.com/back2dos/cix), both of which are much more mature and (frankly) better projects. Pilot mainly includes a few tweaks to make it work better in cross-platform environments (and because I enjoy tinkering with this stuff and pulling other projects apart), and is intentionally less flexible. 

In short: you're almost certainly better off just using Coconut. Go do that.
