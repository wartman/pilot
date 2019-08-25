import pilot.*;

using pilot.Differ;
using pilot.Style;

class Colors {
  public static final blue = 'blue';
  public static final red = 'red';
  public static final grey = '#ccc';
}

class Root implements StyleSheet {
  @:style static var foo = {
    background = Colors.grey;
    boxSizing = 'border-box';
  };
}

class ContainerStyle extends StatelessWidget {

  @:prop var child:VNode;
  @:prop var color:String;
  @:style var root = {
    padding = '10px';
    button = {
      padding = '20px';
    }
    [h1, h2, h3] = {
      fontSize = '12px';
    }

    // @media(
    //   target = 'screen',
    //   mainWidth = '300px'
    // ) {
    //   fontSize = '20px';
    // }
  }
  @:style var red = {
    color = Colors.red;
  }
  @:style var blue = {
    color = Colors.blue;
  }

  override public function build():VNode {
    child.applyStyle([ root, Root.foo, switch color {
      case 'red': red;
      case 'blue': blue;
      default: null;
    } ]);
    return child;
  }

}

class Container extends StatelessWidget {

  @:prop var color:String;
  @:prop var children:Children;
  @:style var test = {
    fontSize = '12px';
  }

  override public function build():VNode {
    return new ContainerStyle({
      color: color,
      child: new VNode({
        name: 'div',
        style: test,
        children: children
      })
    });
  }

}

class Tester extends StatefulWidget {
  
  @:state var color:String = 'blue';

  override function build():VNode {
    return new Container({
      color: color,
      children: [
        'Text!',
        new VNode({
          name: 'button',
          props: {
            onClick: e -> {
              if (color == 'blue') color = 'red';
              else color = 'blue'; 
            }
          },
          children: [ 'Swap ${color}' ]
        }),
        new VNode({
          name: 'h2',
          children: [ 'Test' ]
        })
      ]
    });
  }

}

class Example {

  public static function main() {
    var c = new VNode({
      name: 'div',
      children: [
        new Tester({})
      ]
    });
    var root = js.Browser.document.getElementById('root');
    root.patch(c);
  }

}
