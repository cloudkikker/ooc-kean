/*
 * Copyright(C) 2014 - Simon Mika<simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or(at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see<http://www.gnu.org/licenses/>.
 */

use ooc-base
use ooc-collections
import Constraints

Fixture: abstract class {
	totalTime: static Double
	exitHandlerRegistered: static Bool
	failureNames: static VectorList<String>
	name: String
	tests := VectorList<Test> new(32, false)
	printFailures: static func {
		if (This failureNames && (This failureNames count > 0)) {
			"Failed tests: %i [" printf(This failureNames count)
			for (i in 0 .. This failureNames count - 1)
				(This failureNames[i] + ", ") print()
			(This failureNames[This failureNames count -1] + ']') println()
		}
	}
	init: func (=name) {
		if (!This exitHandlerRegistered) {
			This exitHandlerRegistered = true
			atexit(This printFailures)
		}
	}
	free: override func {
		this tests free()
		this name free()
		super()
	}
	add: func (test: Test) {
		this tests add(test)
	}
	add: func ~action (name: String, action: Func) {
		test := Test new(name, action)
		this add(test)
	}
	run: func -> Bool {
		failures := VectorList<TestFailedException> new(32, false)
		result := true
		This _print(DateTime now toString("%hh:%mm:%ss") + " " + this name + " ")
		timer := ClockTimer new() . start()
		for (i in 0 .. this tests count) {
			test := tests[i]
			This _expectCount = 0
			r := true
			try {
				test run()
				test free()
			} catch (e: TestFailedException) {
				e message = test name
				result = r = false
				failures add(e)
			}
			This _print(r ? "." : "f")
		}
		if (!result) {
			if (!This failureNames)
				This failureNames = VectorList<String> new()
			This failureNames add(this name clone())
		}
		This _print(result ? " done" : " failed")
		testTime := timer stop() / 1000.0
		This totalTime += testTime
		This _print(" in %.2fs, total: %.2fs\n" format(testTime, This totalTime))
		if (!result) {
			for (i in 0 .. failures count) {
				f := failures[i]
				// If the constraint is a CompareConstraint and the value being tested is a Cell,
				// we create a friendly message for the user.
				if (f constraint instanceOf?(CompareConstraint) && f value instanceOf?(Cell))
					(this createFailureMessage(f) toString()) println()
				else
					"  -> '%s' (expect: %i)" printfln(f message, f expect)
				f free()
			}
			This _testsFailed = true
		}
		failures free()
		timer free()
		result
	}
	createFailureMessage: func (failure: TestFailedException) -> Text {
		constraint := failure constraint as CompareConstraint
		// Left is the tested value, right is the correct/expected value
		leftValue := failure value as Cell
		rightValue := constraint correct as Cell
		result := TextBuilder new(t"  -> ")
		result append(Text new(failure message))
		result append(t": expected")
		match (constraint type) {
			case ComparisonType Equal =>
				result append(t" equal to")
			case ComparisonType LessThan =>
				result append(t" less than")
			case ComparisonType GreaterThan =>
				result append(t" greater than")
			case ComparisonType Within =>
				result append(t" equal to")
		}
		result append(Text new(" '%s', was '%s'" format(rightValue toString(), leftValue toString())))
		if (constraint type == ComparisonType Within)
			result append(Text new(" [tolerance: %.8f]" formatDouble((constraint parent as CompareWithinConstraint) precision)))
		result join(' ')
	}
	is ::= static IsConstraints new()
	_expectCount: static Int = 0
	expect: static func (value: Object, constraint: Constraint) {
		++This _expectCount
		if (!constraint verify(value))
			TestFailedException new(value, constraint, This _expectCount) throw()
		else {
			constraint free()
			if (value instanceOf?(Cell))
				(value as Cell) free()
		}
	}
	expect: static func ~char (value: Char, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~text (value: Text, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~boolean (value: Bool, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~integer (value: Int, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~long (value: Long, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~ulong (value: ULong, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~float (value: Float, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~double (value: Double, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~ldouble (value: LDouble, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~isTrue (value: Bool) {
		This expect(Cell new(value), is true)
	}
	expect: static func ~int64 (value: Int64, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	expect: static func ~uint64 (value: UInt64, constraint: Constraint) {
		This expect(Cell new(value), constraint)
	}
	_print: static func (string: String) {
		string print()
		fflush(stdout)
	}
	_testsFailed: static Bool
	testsFailed: static Bool { get { This _testsFailed } }
}

TestFailedException: class extends Exception {
	value: Object
	constraint: Constraint
	expect: Int
	init: func (=value, =constraint, =expect, message := "") {
		this message = message
	}
}

Test: class {
	name: String
	action: Func
	init: func (=name, =action)
	run: func { this action() }
	free: override func {
		(this action as Closure) free()
		this name free()
		super()
	}
}
