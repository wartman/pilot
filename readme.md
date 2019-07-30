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

class Colors {
  public static final red = 'red';
  public static final blue = 'blue';
}

enum abstract ButtonType(Style) to Style {
  var Primary = Style.create({
    // Note that you can pass static final properties to Style rules!
    // This opens up a bit of configuration, with the limitation that
    // (again) the property must be static, final and either a string
    // or an int.
    background: Colors.red
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

Styles
------

Styles can either be injected when the app is started or extracted 
into an external file. If you define `pilot-css=some-name` in 
your hxml, a `css` file will be created alongside your compiled 
code. By default, styles will be injected into the `<head>` when the 
app boots.
