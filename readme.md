Pilot
=====

A batteries-included UI framework.

> Under heavy reworking.

Usage
-----

Pilot handles CSS, HTML and VNode diffing for both browsers and servers, allowing you to use almost the same code across many different targets. Additionally, pilot is quite small: most of the complicated stuff is handled during compiling. 

That's the dream, anyway.

> Note: I'll explain this example later, but it's mostly self-explanatory I think.

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

Lifecycle
---------

Components can have methods marked with lifecycle meta (`@:init`, `@:effect` or `@:dispose`).

`@:init` (or `@:initialize` if you're feeling verbose) will be run _once_ when the Component is constructed.

`@:effect` will be run _every time_ the Component has been rendered and is mounted in the DOM. This is where you'll want to handle things like checking if the user clicked off the component's node (use `getRealNode()` to access the mounted DOM node).

`@:dispose` will be run _once_, after the Component is removed from the DOM. This is where you should handle any cleanup your component needs.

Other Options
-------------

Pilot is heavily based on/inspired by [Coconut](https://github.com/MVCoconut) and [Cix](https://github.com/back2dos/cix), both of which are much more mature and (frankly) better projects. Pilot mainly includes a few tweaks to make it work better in cross-platform environments (and because I enjoy tinkering with this stuff and pulling other projects apart), and is intentionally less flexible. 

In short: you're almost certainly better off just using Coconut. Go do that.
