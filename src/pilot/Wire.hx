package pilot;

import pilot.dom.Node;

interface Wire<Attrs> {
	public function __getNodes():Array<Node>;
	public function __getChildList():Array<Wire<Dynamic>>;
	public function __setChildList(children:Array<Wire<Dynamic>>):Void;
	public function __getWireTypeRegistry():Map<WireType<Dynamic>, WireRegistry>;
	public function __setWireTypeRegistry(types:Map<WireType<Dynamic>, WireRegistry>):Void;
	public function __setup(parent:Wire<Dynamic>, context:Context):Void;
	public function __update(attrs:Attrs, children:Array<VNode>, later:Signal<Any>):Void;
	public function __dispose():Void;
}
