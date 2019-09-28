Pilot
=====

A simple UI framework. At the moment, basically a direct port of  https://github.com/jorgebucaran/superfine with a few little extras.

No tests for now, but the todo example does work.

About
-----

Here's an example pilot `Widget`:

```haxe

import pilot.*;

class Example extends Widget {

  @:prop var title:String;
  @:prop.state var subTitle:String;
  @:style var root = {
    padding: '12px'
  };

  @:hook.prePatch
  public function beforePatching(vn:VNode) {
    trace('About to patch!');
  }

  override function build():VNode {
    return new VNode({
      name: 'div',
      style: root,
      props: {
        className: 'foo'
      },
      children: [
        new VNode({ name: 'h1', children: [ title ] }),
        new VNode({ name: 'h2', children: [ subTitle ] }),
        new VNode({ name: 'button', props: {
          onClick: _ -> subTitle = 'bar';
        }, children: [ 'Change subtitle' ] })
      ]
    });
  }

}

```

... and I'll get around to explaining all that one day...
