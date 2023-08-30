module main

import os
import vasm { OperandType }

struct VMCompiler {
	major u8
	minor u8
	patch u8
mut:
	outpath string
}

// fn main() {
// 	mut app := cli.Command{
// 		name: 'vmc'
// 		description: 'compiler for vasm files'
// 		version: '0.1.0'
// 		disable_man: true
// 		required_args: 1
// 		usage: '<file.vasm>'
// 		execute: fn (cmd cli.Command) ! {
// 			mut vmc := VMCompiler{
// 				major: 0
// 				minor: 1
// 				patch: 0
// 			}

// 			if cmd.flags.any(it.name == 'output') {
// 				vmc.outpath = cmd.flags.filter(it.name == 'output').first().get_string() or {
// 					eprintln('Err: ${err}')
// 					exit(1)
// 				}
// 			}

// 			mut values := cmd.args[0].split('.')
// 			vmc.outpath = values[0] + '.bin'

// 			vmc.compile_program(vasm.load_program(cmd.args[0]))

// 			return
// 		}
// 		flags: [
// 			cli.Flag{
// 				flag: .string
// 				required: false
// 				name: 'output'
// 				abbrev: 'o'
// 				description: 'output file path'
// 			},
// 		]
// 	}

// 	app.setup()
// 	app.parse(os.args)
// }

fn (vmc VMCompiler) compile_program(program []vasm.Instruction) {
	mut buf := []u8{}

	vmc.write_header(mut buf)

	for inst in program {
		buf << u8(inst.typ)
		if inst.has_op {
			write_operand(inst.operand_type, mut buf, inst.operand)
		}
	}

	os.write_file_array(vmc.outpath, buf) or {
		eprintln('Err: ${err}')
		exit(1)
	}
}

fn (vmc VMCompiler) write_header(mut buf []u8) {
	buf << 'VM'.bytes()
	buf << vmc.major
	buf << vmc.minor
	buf << vmc.patch
}

fn write_operand(operand_type OperandType, mut buf []u8, value u64) {
	match operand_type {
		.uint8 {
			write_u8(mut buf, value)
		}
	}
}

fn write_u8(mut buf []u8, value u64) {
	buf << u8(value & 0xFF)
}

fn write_u64(value u64) []u8 {
	mut bytes := []u8{}
	bytes << u8(value)
	bytes << u8(value >> 8)
	bytes << u8(value >> 16)
	bytes << u8(value >> 24)
	bytes << u8(value >> 32)
	bytes << u8(value >> 40)
	bytes << u8(value >> 48)
	bytes << u8(value >> 56)
	return bytes
}
