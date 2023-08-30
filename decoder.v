module decoder

import vasm { Instruction }

struct DecoderVersion {
	major u8
	minor u8
	patch u8
}

fn (decoder_version DecoderVersion) str() string {
	return '${decoder_version.major}.${decoder_version.minor}.${decoder_version.patch}'
}

struct Decoder {
	decoded_insts []DecodedInstruction
pub:
	input_path string
pub mut:
	program []Instruction
}

struct DecodedInstruction {
	pc            u64
	inst_bytecode []u8
	inst_name     string
}

const (
	supported_versions = [DecoderVersion{
		major: 0
		minor: 1
		patch: 0
	}]
)

pub fn decode(bytecode []u8, input_path string) Decoder {
	mut decoder := Decoder{
		input_path: input_path
	}

	mut cursor := u64(0)
	cursor = decoder.parse_header(bytecode, cursor)

	for cursor < bytecode.len {
		inst, cur := decode_inst(bytecode, cursor)
		cursor = cur
		decoder.program << inst
	}

	return decoder
}

fn (decoder Decoder) parse_header(bytecode []u8, cursor u64) u64 {
	decoder_abort(bytecode[0] == 0x56 && bytecode[1] == 0x4D, "Input file isn't a valid binary. ${decoder.input_path}")

	version := DecoderVersion{
		major: bytecode[2]
		minor: bytecode[3]
		patch: bytecode[4]
	}

	decoder_abort(supported_versions.contains(version), 'Binary version not supported! Version: ${version}')

	return cursor + 5
}

fn decode_inst(bytecode []u8, cursor u64) (Instruction, u64) {
	decoder_abort(bytecode[cursor] in vasm.type_by_u8, 'Invalid opcode! ${bytecode[0]:X}')

	inst_type := vasm.type_by_u8[bytecode[cursor]]

	mut op := u64(0)

	mut has_op := false
	mut op_size := u64(0)

	if bytecode[cursor] in vasm.op_size_by_u8 {
		op_size = u64(vasm.op_size_by_u8[bytecode[cursor]])
		has_op = true
		op = read_operand(bytecode, cursor, op_size)
	} else if inst_type == vasm.InstructionType.intrinsic {
		has_op = true
		op_size = u64(1)
		op = read_operand(bytecode, cursor, 1)
	}

	new_cursor := if has_op {
		cursor + 1 + op_size
	} else {
		cursor + 1
	}

	return Instruction{
		typ: inst_type
		operand: op
		has_op: has_op
	}, new_cursor
}

fn read_operand(bytecode []u8, cursor u64, size u64) u64 {
	if size == 1 {
		return u64(bytecode[cursor + 1])
	} else {
		decoder_abort(false, "Read of ${size * 8}bits isn't implemented.")
		exit(1)
	}
}

fn read_u64(b string, cursor u64) u64 {
	bytes := b.bytes()[cursor..cursor + 8]
	val := u64(bytes[0]) | u64(bytes[1]) << 8 | u64(bytes[2]) << 16 | u64(bytes[3]) << 24 | u64(bytes[4]) << 32 | u64(bytes[5]) << 40 | u64(bytes[6]) << 48 | u64(bytes[7]) << 56
	return val
}

fn decoder_abort(cond bool, msg string) {
	if !cond {
		eprintln('DecoderException: ${msg}')
		exit(1)
	}
}
