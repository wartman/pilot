Pilot
=====

A simple UI framework. At the moment, basically a direct port of  https://github.com/jorgebucaran/superfine with a few little extras.

No tests for now, but the todo example does work.

About
-----

Here's an example to give you a basic sense of where I'm going
with this project:

```haxe
package my.ui;

import pilot.StatelessWidget;
import pilot.VNode;
import pilot.Style;

// Styles are compiled to css and output alongside your compiled
// code. You can change its destination by defining `pilot-css`
// in your build `hxml`.
//
// It's important to note that these styles will NOT be present
// in the compiled code. Instead, calls to `Style.create` are 
// replaced with a String that points to a class in the generated
// css file. This means it's safe to use `Style.create` inside of
// loops and `Widget#build`, as we'll see in a second.
enum abstract ButtonType(Style) to Style {
  var Primary = Style.create({
    background: 'red'
  });
  var Secondary = Style.create({
    background: 'gray'
  });
}

class MyButton extends StatelessWidget {

  @:prop var type:ButtonType;
  @:prop var label:String;
  #if js 
    @:prop var onClick:(e:js.html.Event)->Void;
  #end

  override function build() {
    return VNode.h('button', {
      className: Style.compose([
        type,
        Style.create({
          padding: '1em',
          'font-size': '1em',
          'border-radius': '.5em',
          outline: 'none'
        })
      ]),
      #if js
        onClick: onClick
      #end
    }, [ label ])
  }

}

```

For now, check the `example` folder for how this actually gets glued
together (although the way I'm handling `pilot.Style` there is not
ideal).

Ideally this will be good for prototyping or small projects! 
We'll see.
