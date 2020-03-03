Plugins
-------

Plugins might look like this:

```haxe
package pilot;

@:access(pilot.Component)
interface Plugin {
    public function __subscribe(component:Component):Void;
}
```

This would simply hook into a component's lifecycle, allowing us to implement all sorts of handy APIs. Using it is simple: you just pass a Plugin as an attribute, and the Component macro will detect it and wire it up for you.

```haxe
import pilot.Component;

class Example extends Component {

    @:attribute var plugin:SomePlugin = new SomePlugin('stuff');

    // etc

}

```

For example, imagine a Redux-style centralized store called `pilot.message`:

```haxe
package pilot.message;

import pilot.Plugin;

@:autoBuild(pilot.message.Message.build())
class Message<Msg, Data> implements Plugin {

    var __component:Component;
    var __store:Store<Data>;
    var __subscription:SignalSubscription;
    
    public function __subscribe(component:Component) {
        // note: this assumes that we've switched 
        //       to a simple signal implementation
        //       for all pilot lifecycle events:
        __component = component;
        __store = component.__context.get(__getConnectedStoreId());
        component.__onDispose.once(__dispose);
        if (__store == null) {
            throw 'No store registered -- be sure this component '   
                  + 'is inside a StoreProvider';
        }
        __onUpdate(__store.__data, true);
        __subscription = __store.onUpdate.add(__onUpdate);
    }

    public function __dispose() {
        __subscription.cancel();
        __component = null;
        __store = null;
    }

    // this will be set via macro:
    function __getConnectedStoreId() {
        return Store.ID;
    }

    function __onUpdate(data:Data, isInitializing:Bool = false) {
        // implemented by macro
    }

}

```

The macro would work something like this:

```haxe
package someapp.message;

import pilot.message.Store;

enum Route {
    Home;
    Page(id:String);
}

enum Action {
    SetRoute(route:Route);
    SetSiteTitle(title:String);
}

typedef Data = {
    currentPage:Page,
    curentRoute:Route,
    pages:List<Page>,
    siteTitle:String
}

class MyStore extends Store<Data> {

    @:receive
    public function handleAction(action:Action) {
        return switch action {
            // note: this obviously is not a real implementation.
            case SetRoute(route): switch route {
                case Home: { 
                    currentPage: pages.find(p -> p.id == 'home'),
                    currentRoute: route
                };
                case Page(id): {
                    currentPage: pages.find(p -> p.id == id),
                    currentRoute: route
                };
            }
            case SetSiteTitle(title): { siteTitle: title };
        }
    }

}

```

```haxe
package someapp.message;

import pilot.message.Message;

@:connect(MyStore)
class RouteMessage implements Message<Action, Data> {

    // Public properties that can be accessed by the Component.
    @:prop var page:Page;

    // `@:send` functions MUST return `Message.Msg` -- `Route`, in
    //  this case. This will be turned into something like 
    // `__store.sendMessage(setRoute(msg))`
    @:send
    public function go(msg:Route):Action {
        return SetRoute(msg); // All we need to do!
    }

    @:send
    public function goHome():Action {
        return SetRoute(Home);
    }

    // `@:receive` functions are called whenever the Store updates. This
    // works basically the same as an `@:update` method on a Component.
    // This will also be called once when the Message is initialized.
    @:receive
    function routeChanged(data:Data) {
        if (data.currentPage != page) {
            return { page: data.currentPage };
        }
        // Returning `null` will skip any effects.
        return null;
    }

    // Just as an example, this is what the macro will create for 
    // `__onUpdate`, more or less:
    override function __onUpdate(data:Data, isInitializing:Bool = false) {
        var __changed = false;
        if (__component != null) {
            var __p = routeChanged(data);
            if (__p != null) {
                __changed = true;
                page = __p.page;
            }
        }
        if (__changed && !isInitializing) {
            __component.__requestUpdate({});
        }
    }

}

```

```haxe
package someapp.ui;

import pilot.Component;
import someapp.message.RouteMessage;
import someapp.message.SiteMessage;

class SomePage extends Component {

    @:attribute var route:RouteMessage = new RouteMessage();
    @:attribute var site:SiteMessage = new SiteMessage();

    override function render() return html(<>
        <header>
            <h1>
                <a href="#home" onClick={_ -> route.goHome()}>
                    {site.siteTitle}
                </a>
            </h1>
            <h2>{route.page.title}</h2>
        </header>
        // etc.
    </>);

}

```
