<?php
/**
 * Generated by Haxe 4.0.0-rc.3+e3df7a448
 */

use \php\Boot;
use \php\_Boot\HxClosure;
use \php\_Boot\HxException;
use \_Array\ArrayIterator;

/**
 * An Array is a storage for values. You can access it using indexes or
 * with its API.
 * @see https://haxe.org/manual/std-Array.html
 * @see https://haxe.org/manual/lf-array-comprehension.html
 */
final class Array_hx implements \ArrayAccess {
	/**
	 * @var mixed
	 */
	public $arr;
	/**
	 * @var int
	 * The length of `this` Array.
	 */
	public $length;

	/**
	 * @param mixed $arr
	 * 
	 * @return Array_hx
	 */
	static public function wrap ($arr) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:223: characters 3-23
		$a = new Array_hx();
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:224: characters 3-14
		$a->arr = $arr;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:225: characters 3-31
		$a->length = count($arr);
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:226: characters 3-11
		return $a;
	}

	/**
	 * Creates a new Array.
	 * 
	 * @return void
	 */
	public function __construct () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:32: characters 3-36
		$this->arr = [];
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:33: characters 3-13
		$this->length = 0;
	}

	/**
	 * Returns a new Array by appending the elements of `a` to the elements of
	 * `this` Array.
	 * This operation does not modify `this` Array.
	 * If `a` is the empty Array `[]`, a copy of `this` Array is returned.
	 * The length of the returned Array is equal to the sum of `this.length`
	 * and `a.length`.
	 * If `a` is `null`, the result is unspecified.
	 * 
	 * @param Array_hx $a
	 * 
	 * @return Array_hx
	 */
	public function concat ($a) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:37: characters 3-46
		return Array_hx::wrap(array_merge($this->arr, $a->arr));
	}

	/**
	 * Returns a shallow copy of `this` Array.
	 * The elements are not copied and retain their identity, so
	 * `a[i] == a.copy()[i]` is true for any valid `i`. However,
	 * `a == a.copy()` is always false.
	 * 
	 * @return Array_hx
	 */
	public function copy () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:41: characters 3-28
		return (clone $this);
	}

	/**
	 * Returns an Array containing those elements of `this` for which `f`
	 * returned true.
	 * The individual elements are not duplicated and retain their identity.
	 * If `f` is null, the result is unspecified.
	 * 
	 * @param \Closure $f
	 * 
	 * @return Array_hx
	 */
	public function filter ($f) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:45: characters 3-35
		$result = [];
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:46: characters 3-13
		$i = 0;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:47: lines 47-52
		while ($i < $this->length) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:48: lines 48-50
			if ($f($this->arr[$i])) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:49: characters 5-24
				$result[] = $this->arr[$i];
			}
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:51: characters 4-7
			++$i;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:53: characters 3-22
		return Array_hx::wrap($result);
	}

	/**
	 * Returns position of the first occurrence of `x` in `this` Array, searching front to back.
	 * If `x` is found by checking standard equality, the function returns its index.
	 * If `x` is not found, the function returns -1.
	 * If `fromIndex` is specified, it will be used as the starting index to search from,
	 * otherwise search starts with zero index. If it is negative, it will be taken as the
	 * offset from the end of `this` Array to compute the starting index. If given or computed
	 * starting index is less than 0, the whole array will be searched, if it is greater than
	 * or equal to the length of `this` Array, the function returns -1.
	 * 
	 * @param mixed $x
	 * @param int $fromIndex
	 * 
	 * @return int
	 */
	public function indexOf ($x, $fromIndex = null) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:57: characters 7-69
		$tmp = null;
		if (($fromIndex === null) && !($x instanceof HxClosure)) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:57: characters 53-69
			$value = $x;
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:57: characters 7-69
			$tmp = !(is_int($value) || is_float($value));
		} else {
			$tmp = false;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:57: lines 57-64
		if ($tmp) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:58: characters 4-50
			$index = array_search($x, $this->arr, true);
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:59: lines 59-63
			if ($index === false) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:60: characters 5-14
				return -1;
			} else {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:62: characters 5-17
				return $index;
			}
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:65: lines 65-70
		if ($fromIndex === null) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:66: characters 4-17
			$fromIndex = 0;
		} else {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:68: characters 4-42
			if ($fromIndex < 0) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:68: characters 23-42
				$fromIndex += $this->length;
			}
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:69: characters 4-36
			if ($fromIndex < 0) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:69: characters 23-36
				$fromIndex = 0;
			}
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:71: lines 71-75
		while ($fromIndex < $this->length) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:72: lines 72-73
			if (Boot::equal($this->arr[$fromIndex], $x)) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:73: characters 5-21
				return $fromIndex;
			}
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:74: characters 4-15
			++$fromIndex;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:76: characters 3-12
		return -1;
	}

	/**
	 * Inserts the element `x` at the position `pos`.
	 * This operation modifies `this` Array in place.
	 * The offset is calculated like so:
	 * - If `pos` exceeds `this.length`, the offset is `this.length`.
	 * - If `pos` is negative, the offset is calculated from the end of `this`
	 * Array, i.e. `this.length + pos`. If this yields a negative value, the
	 * offset is 0.
	 * - Otherwise, the offset is `pos`.
	 * If the resulting offset does not exceed `this.length`, all elements from
	 * and including that offset to the end of `this` Array are moved one index
	 * ahead.
	 * 
	 * @param int $pos
	 * @param mixed $x
	 * 
	 * @return void
	 */
	public function insert ($pos, $x) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:80: characters 3-11
		$this->length++;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:81: characters 3-56
		array_splice($this->arr, $pos, 0, [$x]);
	}

	/**
	 * Returns an iterator of the Array values.
	 * 
	 * @return object
	 */
	public function iterator () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:86: characters 3-33
		return new ArrayIterator($this);
	}

	/**
	 * Returns a string representation of `this` Array, with `sep` separating
	 * each element.
	 * The result of this operation is equal to `Std.string(this[0]) + sep +
	 * Std.string(this[1]) + sep + ... + sep + Std.string(this[this.length-1])`
	 * If `this` is the empty Array `[]`, the result is the empty String `""`.
	 * If `this` has exactly one element, the result is equal to a call to
	 * `Std.string(this[0])`.
	 * If `sep` is null, the result is unspecified.
	 * 
	 * @param string $sep
	 * 
	 * @return string
	 */
	public function join ($sep) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:90: characters 3-98
		return implode($sep, array_map((Boot::class??'null') . "::stringify", $this->arr));
	}

	/**
	 * Returns position of the last occurrence of `x` in `this` Array, searching back to front.
	 * If `x` is found by checking standard equality, the function returns its index.
	 * If `x` is not found, the function returns -1.
	 * If `fromIndex` is specified, it will be used as the starting index to search from,
	 * otherwise search starts with the last element index. If it is negative, it will be
	 * taken as the offset from the end of `this` Array to compute the starting index. If
	 * given or computed starting index is greater than or equal to the length of `this` Array,
	 * the whole array will be searched, if it is less than 0, the function returns -1.
	 * 
	 * @param mixed $x
	 * @param int $fromIndex
	 * 
	 * @return int
	 */
	public function lastIndexOf ($x, $fromIndex = null) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:94: characters 3-71
		if (($fromIndex === null) || ($fromIndex >= $this->length)) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:94: characters 49-71
			$fromIndex = $this->length - 1;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:95: characters 3-41
		if ($fromIndex < 0) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:95: characters 22-41
			$fromIndex += $this->length;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:96: lines 96-100
		while ($fromIndex >= 0) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:97: lines 97-98
			if (Boot::equal($this->arr[$fromIndex], $x)) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:98: characters 5-21
				return $fromIndex;
			}
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:99: characters 4-15
			--$fromIndex;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:101: characters 3-12
		return -1;
	}

	/**
	 * Creates a new Array by applying function `f` to all elements of `this`.
	 * The order of elements is preserved.
	 * If `f` is null, the result is unspecified.
	 * 
	 * @param \Closure $f
	 * 
	 * @return Array_hx
	 */
	public function map ($f) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:105: characters 3-35
		$result = [];
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:106: characters 3-13
		$i = 0;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:107: lines 107-110
		while ($i < $this->length) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:108: characters 4-26
			$result[] = $f($this->arr[$i]);
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:109: characters 4-7
			++$i;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:111: characters 3-22
		return Array_hx::wrap($result);
	}

	/**
	 * @param int $offset
	 * 
	 * @return bool
	 */
	public function offsetExists ($offset) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:191: characters 3-25
		return $offset < $this->length;
	}

	/**
	 * @param int $offset
	 * 
	 * @return mixed
	 */
	public function &offsetGet ($offset) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:196: lines 196-200
		try {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:197: characters 4-22
			return $this->arr[$offset];
		} catch (\Throwable $__hx__caught_e) {
			$__hx__real_e = ($__hx__caught_e instanceof HxException ? $__hx__caught_e->e : $__hx__caught_e);
			$e = $__hx__real_e;
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:199: characters 4-15
			return null;
		}
	}

	/**
	 * @param int $offset
	 * @param mixed $value
	 * 
	 * @return void
	 */
	public function offsetSet ($offset, $value) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:205: lines 205-210
		if ($this->length <= $offset) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:206: lines 206-208
			if ($this->length < $offset) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:207: characters 5-50
				$this->arr = array_pad($this->arr, $offset + 1, null);
			}
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:209: characters 4-23
			$this->length = $offset + 1;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:211: characters 3-22
		$this->arr[$offset] = $value;
	}

	/**
	 * @param int $offset
	 * 
	 * @return void
	 */
	public function offsetUnset ($offset) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:216: lines 216-219
		if (($offset >= 0) && ($offset < $this->length)) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:217: characters 4-39
			array_splice($this->arr, $offset, 1);
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:218: characters 4-12
			--$this->length;
		}
	}

	/**
	 * Removes the last element of `this` Array and returns it.
	 * This operation modifies `this` Array in place.
	 * If `this` has at least one element, `this.length` will decrease by 1.
	 * If `this` is the empty Array `[]`, null is returned and the length
	 * remains 0.
	 * 
	 * @return mixed
	 */
	public function pop () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:115: characters 3-27
		if ($this->length > 0) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:115: characters 19-27
			$this->length--;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:116: characters 3-31
		return array_pop($this->arr);
	}

	/**
	 * Adds the element `x` at the end of `this` Array and returns the new
	 * length of `this` Array.
	 * This operation modifies `this` Array in place.
	 * `this.length` increases by 1.
	 * 
	 * @param mixed $x
	 * 
	 * @return int
	 */
	public function push ($x) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:120: characters 3-18
		$this->arr[$this->length] = $x;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:121: characters 3-18
		return ++$this->length;
	}

	/**
	 * Removes the first occurrence of `x` in `this` Array.
	 * This operation modifies `this` Array in place.
	 * If `x` is found by checking standard equality, it is removed from `this`
	 * Array and all following elements are reindexed accordingly. The function
	 * then returns true.
	 * If `x` is not found, `this` Array is not changed and the function
	 * returns false.
	 * 
	 * @param mixed $x
	 * 
	 * @return bool
	 */
	public function remove ($x) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:124: lines 124-135
		$_gthis = $this;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:125: characters 3-22
		$result = false;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:126: lines 126-133
		$collection = $this->arr;
		foreach ($collection as $key => $value) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:127: lines 127-132
			if (Boot::equal($value, $x)) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:128: characters 5-39
				array_splice($_gthis->arr, $key, 1);
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:129: characters 5-13
				$_gthis->length--;
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:130: characters 5-18
				$result = true;
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:131: characters 5-25
				break;
			}
		}

		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:134: characters 3-16
		return $result;
	}

	/**
	 * Set the length of the Array.
	 * If `len` is shorter than the array's current size, the last
	 * `length - len` elements will be removed. If `len` is longer, the Array
	 * will be extended, with new elements set to a target-specific default
	 * value:
	 * - always null on dynamic targets
	 * - 0, 0.0 or false for Int, Float and Bool respectively on static targets
	 * - null for other types on static targets
	 * 
	 * @param int $len
	 * 
	 * @return void
	 */
	public function resize ($len) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:181: lines 181-185
		if ($this->length < $len) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:182: characters 4-42
			$this->arr = array_pad($this->arr, $len, null);
		} else if ($this->length > $len) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:184: characters 4-47
			array_splice($this->arr, $len, $this->length - $len);
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:186: characters 3-15
		$this->length = $len;
	}

	/**
	 * Reverse the order of elements of `this` Array.
	 * This operation modifies `this` Array in place.
	 * If `this.length < 2`, `this` remains unchanged.
	 * 
	 * @return void
	 */
	public function reverse () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:138: characters 3-34
		$this->arr = array_reverse($this->arr);
	}

	/**
	 * Removes the first element of `this` Array and returns it.
	 * This operation modifies `this` Array in place.
	 * If `this` has at least one element, `this`.length and the index of each
	 * remaining element is decreased by 1.
	 * If `this` is the empty Array `[]`, `null` is returned and the length
	 * remains 0.
	 * 
	 * @return mixed
	 */
	public function shift () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:142: characters 3-27
		if ($this->length > 0) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:142: characters 19-27
			$this->length--;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:143: characters 3-33
		return array_shift($this->arr);
	}

	/**
	 * Creates a shallow copy of the range of `this` Array, starting at and
	 * including `pos`, up to but not including `end`.
	 * This operation does not modify `this` Array.
	 * The elements are not copied and retain their identity.
	 * If `end` is omitted or exceeds `this.length`, it defaults to the end of
	 * `this` Array.
	 * If `pos` or `end` are negative, their offsets are calculated from the
	 * end of `this` Array by `this.length + pos` and `this.length + end`
	 * respectively. If this yields a negative value, 0 is used instead.
	 * If `pos` exceeds `this.length` or if `end` is less than or equals
	 * `pos`, the result is `[]`.
	 * 
	 * @param int $pos
	 * @param int $end
	 * 
	 * @return Array_hx
	 */
	public function slice ($pos, $end = null) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:147: characters 3-29
		if ($pos < 0) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:147: characters 16-29
			$pos += $this->length;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:148: characters 3-23
		if ($pos < 0) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:148: characters 16-23
			$pos = 0;
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:149: lines 149-158
		if ($end === null) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:150: characters 4-45
			return Array_hx::wrap(array_slice($this->arr, $pos));
		} else {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:152: characters 4-30
			if ($end < 0) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:152: characters 17-30
				$end += $this->length;
			}
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:153: lines 153-157
			if ($end <= $pos) {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:154: characters 5-14
				return new Array_hx();
			} else {
				#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:156: characters 5-57
				return Array_hx::wrap(array_slice($this->arr, $pos, $end - $pos));
			}
		}
	}

	/**
	 * Sorts `this` Array according to the comparison function `f`, where
	 * `f(x,y)` returns 0 if x == y, a positive Int if x > y and a
	 * negative Int if x < y.
	 * This operation modifies `this` Array in place.
	 * The sort operation is not guaranteed to be stable, which means that the
	 * order of equal elements may not be retained. For a stable Array sorting
	 * algorithm, `haxe.ds.ArraySort.sort()` can be used instead.
	 * If `f` is null, the result is unspecified.
	 * 
	 * @param \Closure $f
	 * 
	 * @return void
	 */
	public function sort ($f) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:162: characters 3-15
		usort($this->arr, $f);
	}

	/**
	 * Removes `len` elements from `this` Array, starting at and including
	 * `pos`, an returns them.
	 * This operation modifies `this` Array in place.
	 * If `len` is < 0 or `pos` exceeds `this`.length, an empty Array [] is
	 * returned and `this` Array is unchanged.
	 * If `pos` is negative, its value is calculated from the end	of `this`
	 * Array by `this.length + pos`. If this yields a negative value, 0 is
	 * used instead.
	 * If the sum of the resulting values for `len` and `pos` exceed
	 * `this.length`, this operation will affect the elements from `pos` to the
	 * end of `this` Array.
	 * The length of the returned Array is equal to the new length of `this`
	 * Array subtracted from the original length of `this` Array. In other
	 * words, each element of the original `this` Array either remains in
	 * `this` Array or becomes an element of the returned Array.
	 * 
	 * @param int $pos
	 * @param int $len
	 * 
	 * @return Array_hx
	 */
	public function splice ($pos, $len) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:166: characters 3-25
		if ($len < 0) {
			#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:166: characters 16-25
			return new Array_hx();
		}
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:167: characters 3-57
		$result = Array_hx::wrap(array_splice($this->arr, $pos, $len));
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:168: characters 3-26
		$this->length -= $result->length;
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:169: characters 3-16
		return $result;
	}

	/**
	 * Returns a string representation of `this` Array.
	 * The result will include the individual elements' String representations
	 * separated by comma. The enclosing [ ] may be missing on some platforms,
	 * use `Std.string()` to get a String representation that is consistent
	 * across platforms.
	 * 
	 * @return string
	 */
	public function toString () {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:177: characters 10-54
		$arr = $this->arr;
		$strings = [];
		foreach ($arr as $key => $value) {
			$strings[$key] = Boot::stringify($value, 9);
		}
		return "[" . (implode(",", $strings)??'null') . "]";
	}

	/**
	 * Adds the element `x` at the start of `this` Array.
	 * This operation modifies `this` Array in place.
	 * `this.length` and the index of each Array element increases by 1.
	 * 
	 * @param mixed $x
	 * 
	 * @return void
	 */
	public function unshift ($x) {
		#C:\Users\wartman\AppData\Roaming/haxe/versions/4.0.0-rc.3/std/php/_std/Array.hx:173: characters 3-40
		$this->length = array_unshift($this->arr, $x);
	}

	public function __toString() {
		return $this->toString();
	}
}

Boot::registerClass(Array_hx::class, 'Array');
