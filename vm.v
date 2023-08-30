module main

import os
import datatypes { Stack }
import vasm { BinopType, IntrinsicType }
import decoder
import cli { Command }

pub struct Machine {
mut:
	stack Stack[u64]
pub mut:
	program []vasm.Instruction
}

fn main() {
	mut app := Command{
		name: 'vm'
		disable_man: true
		commands: [
			Command{
				name: 'run'
				usage: '<file.bin>'
				required_args: 1
				execute: fn (cmd Command) ! {
					mut vm := create_vm()

					bytecode := os.read_file(cmd.args[0]) or {
						eprintln('Err: ${err}')
						exit(1)
					}.bytes()

					decoder := decoder.decode(bytecode, 'dummy')

					vm.program << decoder.program
					vm.run()

					vm.abort(vm.stack.is_empty(), 'Exit program with unused data on the stack! Data: ${vm.stack}')
					return
				}
			},
			Command{
				name: 'comp'
				usage: '<file.asm>'
				required_args: 1
				execute: fn (cmd Command) ! {
					mut vmc := VMCompiler{
						major: 0
						minor: 1
						patch: 0
					}

					if cmd.flags.any(it.name == 'output') {
						vmc.outpath = cmd.flags.filter(it.name == 'output').first().get_string() or {
							eprintln('Err: ${err}')
							exit(1)
						}
					}

					mut values := cmd.args[0].split('.')
					vmc.outpath = values[0] + '.bin'

					vmc.compile_program(vasm.load_program(cmd.args[0]))

					return
				}
				flags: [
					cli.Flag{
						flag: .string
						required: false
						name: 'output'
						abbrev: 'o'
						description: 'output file path'
					},
				]
			},
		]
	}

	app.setup()
	app.parse(os.args)
}

pub fn create_vm() Machine {
	return Machine{
		stack: Stack[u64]{}
		program: []vasm.Instruction{}
	}
}

pub fn (mut machine Machine) run() {
	for instruction in machine.program {
		match instruction.typ {
			.push_u8 {
				assert instruction.operand_type == .uint8
				machine.push_u8(u8(instruction.operand))
			}
			.plus_u8 {
				machine.binop_u8(.plus)
			}
			.minus_u8 {
				machine.binop_u8(.minus)
			}
			.mult_u8 {
				machine.binop_u8(.mult)
			}
			.div_u8 {
				machine.binop_u8(.div)
			}
			.mod_u8 {
				machine.binop_u8(.mod)
			}
			.intrinsic {
				match instruction.operand {
					u64(IntrinsicType.println) {
						println(machine.stack_pop())
					}
					u64(IntrinsicType.drop) {
						machine.abort(!machine.stack.is_empty(), 'Drop requires values on the stack!')
						machine.stack_pop()
					}
					else {
						panic('Unreachable! Unknown intrinsic: ${instruction.operand}')
					}
				}
			}
		}
	}
}

pub fn (mut vm Machine) stack_pop() u64 {
	return vm.stack.pop() or {
		println('Err: ${err}')
		exit(1)
	}
}

pub fn (vm Machine) stack_peek() u64 {
	return vm.stack.peek() or {
		println('Err: ${err}')
		exit(1)
	}
}

pub fn (mut vm Machine) push_u8(value u8) {
	vm.stack.push(value)
}

pub fn (mut vm Machine) binop_u8(binop_type BinopType) {
	vm.abort(vm.stack.len() >= 2, 'Stack underflow. Binop instructions requires two values in the stack')

	a := vm.stack_pop()
	b := vm.stack_pop()

	match binop_type {
		.plus {
			vm.stack.push(a + b)
		}
		.minus {
			vm.stack.push(a - b)
		}
		.mult {
			vm.stack.push(a * b)
		}
		.div {
			vm.stack.push(a / b)
		}
		.mod {
			vm.stack.push(a % b)
		}
	}
}

fn (vm Machine) abort(cond bool, msg string) {
	if !cond {
		eprintln('VMException: ${msg}')
		exit(1)
	}
}
