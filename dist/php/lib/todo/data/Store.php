<?php
/**
 * Generated by Haxe 4.0.0-rc.3+e3df7a448
 */

namespace todo\data;

use \php\Boot;
use \pilot\Renderer;

class Store {
	/**
	 * @var bool
	 */
	public $_allSelected;
	/**
	 * @var \Array_hx
	 */
	public $_visibleTodos;
	/**
	 * @var \Closure
	 */
	public $build;
	/**
	 * @var VisibleTodos
	 */
	public $filter;
	/**
	 * @var \Array_hx
	 */
	public $todos;

	/**
	 * @param \Closure $build
	 * 
	 * @return void
	 */
	public function __construct ($build) {
		#example/todo/data/Store.hx:29: characters 35-39
		$this->_visibleTodos = null;
		#example/todo/data/Store.hx:17: characters 27-31
		$this->_allSelected = null;
		#example/todo/data/Store.hx:15: characters 36-46
		$this->filter = VisibleTodos::VisibleAll();
		#example/todo/data/Store.hx:13: characters 27-29
		$this->todos = new \Array_hx();
		#example/todo/data/Store.hx:61: characters 7-25
		$this->build = $build;
	}

	/**
	 * @param Todo $todo
	 * 
	 * @return void
	 */
	public function addTodo ($todo1) {
		#example/todo/data/Store.hx:74: characters 5-21
		$_this = $this->todos;
		$_this->arr[$_this->length] = $todo1;
		++$_this->length;

		#example/todo/data/Store.hx:75: characters 5-13
		$this->update();
	}

	/**
	 * @return void
	 */
	public function clearCompleted () {
		#example/todo/data/Store.hx:116: characters 20-56
		$_this = null;
		#example/todo/data/Store.hx:116: characters 20-32
		if ($this->_visibleTodos !== null) {
			#example/todo/data/Store.hx:116: characters 20-56
			$_this = $this->_visibleTodos;
		} else {
			#example/todo/data/Store.hx:116: characters 20-32
			$filtered = (clone $this->todos);
			$filtered->arr = array_reverse($filtered->arr);
			$_this1 = null;
			$__hx__switch = ($this->filter->index);
			if ($__hx__switch === 0) {
				$_this1 = $filtered;
			} else if ($__hx__switch === 1) {
				$result = [];
				$i = 0;
				while ($i < $filtered->length) {
					if ($filtered->arr[$i]->complete) {
						$result[] = $filtered->arr[$i];
					}
					++$i;
				}
				$_this1 = \Array_hx::wrap($result);
			} else if ($__hx__switch === 2) {
				$result1 = [];
				$i1 = 0;
				while ($i1 < $filtered->length) {
					if (!$filtered->arr[$i1]->complete) {
						$result1[] = $filtered->arr[$i1];
					}
					++$i1;
				}
				$_this1 = \Array_hx::wrap($result1);
			}
			$this->_visibleTodos = $_this1;
			#example/todo/data/Store.hx:116: characters 20-56
			$_this = $this->_visibleTodos;
		}
		$result2 = [];
		$i2 = 0;
		while ($i2 < $_this->length) {
			if ($_this->arr[$i2]->complete) {
				$result2[] = $_this->arr[$i2];
			}
			++$i2;
		}
		#example/todo/data/Store.hx:116: characters 5-57
		$toRemove = \Array_hx::wrap($result2);
		#example/todo/data/Store.hx:117: characters 5-37
		if ($toRemove->length === 0) {
			#example/todo/data/Store.hx:117: characters 31-37
			return;
		}
		#example/todo/data/Store.hx:118: lines 118-120
		$_g = 0;
		while ($_g < $toRemove->length) {
			#example/todo/data/Store.hx:119: characters 7-22
			$this->todos->remove(($toRemove->arr[$_g++] ?? null));
		}

		#example/todo/data/Store.hx:121: characters 5-13
		$this->update();
	}

	/**
	 * @return \Array_hx
	 */
	public function getTodos () {
		#example/todo/data/Store.hx:70: characters 5-17
		return $this->todos;
	}

	/**
	 * @return bool
	 */
	public function get_allSelected () {
		#example/todo/data/Store.hx:20: characters 5-50
		if ($this->_allSelected !== null) {
			#example/todo/data/Store.hx:20: characters 31-50
			return $this->_allSelected;
		}
		#example/todo/data/Store.hx:21: characters 9-21
		$tmp = null;
		if ($this->_visibleTodos !== null) {
			$tmp = $this->_visibleTodos;
		} else {
			$filtered = (clone $this->todos);
			$filtered->arr = array_reverse($filtered->arr);
			$tmp1 = null;
			$__hx__switch = ($this->filter->index);
			if ($__hx__switch === 0) {
				$tmp1 = $filtered;
			} else if ($__hx__switch === 1) {
				$result = [];
				$i = 0;
				while ($i < $filtered->length) {
					if ($filtered->arr[$i]->complete) {
						$result[] = $filtered->arr[$i];
					}
					++$i;
				}
				$tmp1 = \Array_hx::wrap($result);
			} else if ($__hx__switch === 2) {
				$result1 = [];
				$i1 = 0;
				while ($i1 < $filtered->length) {
					if (!$filtered->arr[$i1]->complete) {
						$result1[] = $filtered->arr[$i1];
					}
					++$i1;
				}
				$tmp1 = \Array_hx::wrap($result1);
			}
			$this->_visibleTodos = $tmp1;
			$tmp = $this->_visibleTodos;
		}
		#example/todo/data/Store.hx:21: lines 21-24
		if ($tmp->length === 0) {
			#example/todo/data/Store.hx:22: characters 7-27
			$this->_allSelected = false;
			#example/todo/data/Store.hx:23: characters 7-26
			return $this->_allSelected;
		}
		#example/todo/data/Store.hx:25: characters 20-57
		$_this = null;
		#example/todo/data/Store.hx:25: characters 20-32
		if ($this->_visibleTodos !== null) {
			#example/todo/data/Store.hx:25: characters 20-57
			$_this = $this->_visibleTodos;
		} else {
			#example/todo/data/Store.hx:25: characters 20-32
			$filtered1 = (clone $this->todos);
			$filtered1->arr = array_reverse($filtered1->arr);
			$_this1 = null;
			$__hx__switch = ($this->filter->index);
			if ($__hx__switch === 0) {
				$_this1 = $filtered1;
			} else if ($__hx__switch === 1) {
				$result2 = [];
				$i2 = 0;
				while ($i2 < $filtered1->length) {
					if ($filtered1->arr[$i2]->complete) {
						$result2[] = $filtered1->arr[$i2];
					}
					++$i2;
				}
				$_this1 = \Array_hx::wrap($result2);
			} else if ($__hx__switch === 2) {
				$result3 = [];
				$i3 = 0;
				while ($i3 < $filtered1->length) {
					if (!$filtered1->arr[$i3]->complete) {
						$result3[] = $filtered1->arr[$i3];
					}
					++$i3;
				}
				$_this1 = \Array_hx::wrap($result3);
			}
			$this->_visibleTodos = $_this1;
			#example/todo/data/Store.hx:25: characters 20-57
			$_this = $this->_visibleTodos;
		}
		$result4 = [];
		$i4 = 0;
		while ($i4 < $_this->length) {
			if (!$_this->arr[$i4]->complete) {
				$result4[] = $_this->arr[$i4];
			}
			++$i4;
		}
		#example/todo/data/Store.hx:25: characters 5-69
		$this->_allSelected = \Array_hx::wrap($result4)->length === 0;
		#example/todo/data/Store.hx:26: characters 5-24
		return $this->_allSelected;
	}

	/**
	 * @return void
	 */
	public function update () {
		#example/todo/data/Store.hx:65: characters 7-38
		echo(\Std::string(Renderer::render(($this->build)($this))));
	}
}

Boot::registerClass(Store::class, 'todo.data.Store');
Boot::registerGetters('todo\\data\\Store', [
	'allSelected' => true
]);