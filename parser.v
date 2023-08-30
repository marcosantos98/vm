module vasm

import os

struct Location {
	col      u64
	row      u64
	filepath string
}

fn (loc Location) str() string {
	return '${loc.filepath}:${loc.row}:${loc.col}'
}

pub fn load_program(filepath string) []Instruction {
	bytes := os.read_file(filepath) or {
		println('Err: ${err}')
		exit(1)
	}

	mut program := []Instruction{}

	mut row := u64(1)
	mut loc := Location{
		row: row
		filepath: filepath
	}
	for line in bytes.split_into_lines() {
		if line.starts_with(';') {
			continue
		}
		row++
		words := line.split(' ')
		match words[0] {
			'push_u8' {
				parser_abort(words.len == 2, loc, '[push_u8] requires only one argument. Found: ${words.len - 1}, ${words[1..]}')
				capacity_check_u8(loc, words[1].u64(), 0xFF)
				program << inst_push_u8(words[1].u8())
			}
			'plus_u8' {
				parser_abort(words.len == 1, loc, '[plus_u8] doesn\'t contain any arguments. Found ${words.len - 2}, ${words[1..]}')
				program << inst_binop_u8(.plus)
			}
			'minus_u8' {
				parser_abort(words.len == 1, loc, '[minus_u8] doesn\'t contain any arguments. Found ${words.len - 2}, ${words[1..]}')
				program << inst_binop_u8(.minus)
			}
			'mult_u8' {
				parser_abort(words.len == 1, loc, '[mult_u8] doesn\'t contain any arguments. Found ${words.len - 2}, ${words[1..]}')
				program << inst_binop_u8(.mult)
			}
			'div_u8' {
				parser_abort(words.len == 1, loc, '[div_u8] doesn\'t contain any arguments. Found ${words.len - 2}, ${words[1..]}')
				program << inst_binop_u8(.div)
			}
			'mod_u8' {
				parser_abort(words.len == 1, loc, '[mod_u8] doesn\'t contain any arguments. Found ${words.len - 2}, ${words[1..]}')
				program << inst_binop_u8(.mod)
			}
			'println' {
				parser_abort(words.len == 1, loc, '[println] doesn\'t contain any arguments. Found ${words.len - 2}, ${words[1..]}')
				program << Instruction{
					typ: .intrinsic
					operand: u64(IntrinsicType.println)
					has_op: true
				}
			}
			'drop' {
				program << Instruction{
					typ: .intrinsic
					operand: u64(IntrinsicType.drop)
					has_op: true
				}
			}
			else {
				panic('Unreachable: Unknown instruction ${words[0]}')
			}
		}
		row++
	}

	return program
}

fn capacity_check_u8(loc Location, value u64, max u64) {
	parser_abort(value <= max, loc, '[.._u8] given operand overflows u8 capacity. ${value} > ${max}')
}

fn parser_abort(cond bool, loc Location, msg string) {
	if !cond {
		eprintln('ParserException: ${loc}: ${msg}')
		exit(1)
	}
}
