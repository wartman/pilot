<?php
/**
 * Generated by Haxe 4.0.0-rc.3+e3df7a448
 */

namespace todo\ui;

use \php\_Boot\HxAnon;
use \php\Boot;
use \pilot\_VNode\VNode_Impl_;
use \pilot\StatelessWidget;

class TodoInput extends StatelessWidget {
	/**
	 * @var object
	 */
	public $_pilot_props;

	/**
	 * @param object $props
	 * 
	 * @return void
	 */
	public function __construct ($props) {
		#src/pilot/macro/WidgetBuilder.hx:93: characters 9-31
		$this->_pilot_props = new HxAnon();
		#src/pilot/macro/WidgetBuilder.hx:33: characters 33-92
		$this->_pilot_props->inputClass = ($props->inputClass === null ? "edit" : $props->inputClass);
		$this->_pilot_props->placeholder = ($props->placeholder === null ? "What needs doing?" : $props->placeholder);
		#src/pilot/macro/WidgetBuilder.hx:35: characters 33-65
		$this->_pilot_props->value = $props->value;
		$this->_pilot_props->save = $props->save;

	}

	/**
	 * @return object
	 */
	public function build () {
		#example/todo/ui/TodoInput.hx:22: lines 22-68
		$props_style = "todo-input";
		#example/todo/ui/TodoInput.hx:50: lines 50-67
		$children = \Array_hx::wrap([VNode_Impl_::_new(new HxAnon([
			"name" => "input",
			"props" => new HxAnon([
				"className" => $this->_pilot_props->inputClass,
				"value" => $this->_pilot_props->value,
				"placeholder" => $this->_pilot_props->placeholder,
			]),
			"children" => new \Array_hx(),
		]))]);
		#example/todo/ui/TodoInput.hx:22: lines 22-68
		$props_child = VNode_Impl_::_new(new HxAnon([
			"name" => "div",
			"props" => new HxAnon(),
			"children" => ($children !== null ? $children : new \Array_hx()),
		]));
		if (\Reflect::hasField($props_child->props, "className")) {
			$_g = \Reflect::field($props_child->props, "className");
			$props_style = ($_g === null ? "todo-input" : "todo-input" . " " . ($_g??'null'));
		}
		\Reflect::setField($props_child->props, "className", $props_style);
		return $props_child;
	}
}

Boot::registerClass(TodoInput::class, 'todo.ui.TodoInput');