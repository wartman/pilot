Pilot
=====

A simple UI framework, based heavily on [Superfine](https://github.com/jorgebucaran/superfine) under the hood.

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

  @:hook.before
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

Hook Lifecycle
--------------

Hooks can be added in two ways: 

