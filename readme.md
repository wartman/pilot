Pilot
=====
[![Build Status](https://travis-ci.com/wartman/pilot.svg?branch=master)](https://travis-ci.com/wartman/pilot)

A batteries-included UI framework.

Usage
-----

Pilot handles CSS, HTML and VNode diffing for both browsers and servers, allowing you to use almost the same code across many different targets.

```haxe

import pilot.Component;

class App extends Component {

  @:attribute(state) var shouldShowExample:Bool = false;

  override function render() return html(<div>
    @if (shouldShowExample)
      <Example foo="Some Foo" />
    else
      <>Nothing to show here!</>
    <button onClick={_ -> shouldShowExample = !shouldShowExample}>
      Toggle
    </button>
  </div>);

}

class Example extends Component {

  @:attribute var foo:String;

  override function render() return html(<div class={css('
    height: 20px;
    line-height: 20px;
  ')}>
    <h1>${foo}</h1>
    <button onClick={_ -> changeFoo(foo + 'foo')}>Change</button>
  </div>);

  // Instead of making an attribute a `state`, you can define
  // `update` methods like this, which will re-render the 
  // view when they are called:
  @:update
  function changeFoo(newFoo:String) {
    // The returned object is mapped to the Component's attributes --
    // even stateless attributes may be changed here. This is similar
    // to calling `setState` on React components.
    return {
      foo: newFoo
    };
  }

}

class Main {

  public static function main() {
    // Define global styles:
    Pilot.css('
      body {
        background: black;
        color: white;
      }
    ', { global: true });

    Pilot.mount(
      // `Pilot.document` is an alias for `js.Browser.document` on
      // js targets or for `pilot.dom.Document.root` on sys targets
      // (which uses Pilot's minimal DOM) 
      Pilot.document.body,
      Pilot.html(<App shouldShowExample={true} />)
    );
  }

}

```

Examples
--------

- [TodoMVC](https://github.com/wartman/pilot.todo)

Lifecycle
---------

Components can have methods marked with lifecycle meta (`@:init`, `@:effect`, `@:dispose` or `@:guard`).

`@:init` will be run _once_ when the Component is constructed.

`@:effect` will be run _every time_ the Component has been rendered and is mounted in the DOM. This is where you'll want to handle things like checking if the user clicked off the component's node (use `getRealNode()` to access the mounted DOM node). You can determine if effects should run with the `guard` option, which might look something like this: `@:effect(guard = someAttribute != null)`.

`@:dispose` will be run _once_, after the Component is removed from the DOM. This is where you should handle any cleanup your component needs.

Methods with `@:guard` meta will be checked before every render -- if ANY `@:guard` methods return false the component will not be rendered. 

State
-----

`pilot.State` works a little like a mix of redux and the provider/consumer system in React.

A `State` looks a lot like a typical component at first, although it does not allow you to define a `render` method:

```haxe
class MyState extends State {

  @:attribute var foo:String;

  @:transition
  public function setFoo(foo:String) {
    return { foo: foo };
  }

}
```

The main benefit of using States is that you can `consume` them from any component in your app, so long as there is a parent State in the VNode tree. For example:

```haxe
class UsesState extends Component {

  // note that only `pilot.State`s can be consumed.
  @:attribute(consume) var state:MyState;

  override function render() return html(<>
    <p>{state.foo}</p>
    <button onClick={e -> state.setFoo('bar')}>Make Bar</button>
  </>)

}
```

You can then set your app up like this:

```haxe
Pilot.html(<>
  <MyState foo="foo">
    // Note that we don't need to pass anything to
    // <UsesState>'s `state` attribute -- it will be injected
    // automatically so long as there is a <MyState> parent.
    <UsesState />
  </MyState>
</>)
```

This example is contrived, but this pattern becomes far more useful when you have deeply nested components that still need to access or change higher-level states.

Special Attributes
------------------

There are three special attributes (for now) you can use: `@ref`, `@key` and `@dangrouslySetInnerHtml`:

```haxe
Pilot.html(
  <div
    @ref={node -> {
      // Allows access to the real DOM (if a JS target) or to Pilot's
      // very limited DOM implementation (for Sys targets). 
      trace(node);
    }}
    @key="A unique key!"
    @dangrouslySetInnerHtml="
      <p>This will replace the innerHTML of this element.</p>
      <p>
        It won't get escaped or validated or anything, so you should
        be cautious with it.
      </p>
      <script>
        alert('this will probably get run, for example');
      </script>
    "
  >foo</div>
);
```

Control Flow
------------

You can use `if`, `for` and `switch` inline in markup if you prefix them with `@`:

```haxe
var foos = [ 'a', 'b', 'c' ];
Pilot.html(<>
  @if (foos.length == 0) {
    'No foos!';
  } @else {
    // We can use markup inside conditionals:
    <ul>

      // Brackets are not required if there is only a
      // single node expression:
      @for (foo in foos) <li>{foo}</li>

      // However, you can use brackets if needed, which could
      // look something like this:
      //
      //   @for (foo in foos) {
      //     var value = 'foo_${foo}';
      //     <li>{value}</li>;
      //   }

    </ul>;
  }
</>);
```

This syntax is optional: the following code will yield the same result:

```haxe
var foos = [ 'a', 'b', 'c' ];
Pilot.html(<>
  {
    if (foos.length == 0) 
      <span>No foos!</span>
    else
      <ul>{
        [ for (foo in foos) <li>{foo}</li> ]
      }</ul>
  }
</>);
```

If you want to turn off inline control flow entirely, you can set:

```hxml
-D pilot-markup-no-inline-control-flow
```

in your HXML, or by using `html(<>...</>, { noInlineControlFlow: true })`.

Without Using Markup
--------------------
You can create Pilot apps without using the `Pilot.html` markup macro fairly easily. All pilot Components have a static `node` method that returns a `VComponent`, and the `pilot.Html` class has simple `h` and `text` helper methods to create `VNodes`.

```haxe

import pilot.Html;

Pilot.mount(
  js.Browser.document.getElementById('root'),
  Html.h('div', {}, [
    MyComponent.node({
      name: 'foo',
      children: [
        Html.text('Bar')
      ]
    })
  ])
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

class MyComponent extends Component {

  override function render() return html(
    <div class={css('
      background: blue
    ', { 
      // Simply set `embed` as `true` in the `css` options!  
      embed: true
    })}>
      <p>Stuff</p>
    </div>
  );

}
```

Note that you CAN use embedded styles in `sys` targets, you'll just need to put `pilot.StyleManager.toString()` somewhere to render the styles (this is not recommended, by the way).

Other Options
-------------

Pilot is heavily based on/inspired by [Coconut](https://github.com/MVCoconut) and [Cix](https://github.com/back2dos/cix), both of which are much more mature and (frankly) better projects. Pilot mainly includes a few tweaks to make it work better in cross-platform environments (and because I enjoy tinkering with this stuff and pulling other projects apart), and is intentionally less flexible. 

In short: you're almost certainly better off just using Coconut. Go do that.
