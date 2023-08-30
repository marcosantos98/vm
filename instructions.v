module vasm

pub const type_by_u8 = {
	0:   InstructionType.push_u8
	1:   InstructionType.plus_u8
	2:   InstructionType.minus_u8
	3:   InstructionType.mult_u8
	4:   InstructionType.div_u8
	5:   InstructionType.mod_u8
	254: InstructionType.intrinsic
}

pub const name_by_u8 = {
	0:   'push_u8'
	1:   'plus_u8'
	2:   'minus_u8'
	3:   'mult_u8'
	4:   'div_u8'
	5:   'mod_u8'
	254: 'intrinsic'
}

pub const op_size_by_u8 = {
	0: 1
}

pub struct Instruction {
pub:
	typ          InstructionType
	operand      u64
	operand_type OperandType
	has_op       bool
}

pub enum InstructionType as u8 {
	push_u8
	plus_u8
	minus_u8
	mult_u8
	div_u8
	mod_u8
	intrinsic = 0xFE // 0xFF overflows u8 type for some reason
}

pub enum OperandType as u8 {
	uint8
}

pub enum IntrinsicType as u8 {
	println
	drop
	exit
}

pub enum BinopType {
	plus
	minus
	mult
	div
	mod
}

pub fn inst_push_u8(operand u8) Instruction {
	return Instruction{
		operand: operand
		typ: .push_u8
		operand_type: .uint8
		has_op: true
	}
}

pub fn inst_binop_u8(binop_type BinopType) Instruction {
	mut typ := InstructionType.plus_u8
	match binop_type {
		.plus {
			typ = .plus_u8
		}
		.minus {
			typ = .minus_u8
		}
		.mult {
			typ = .mult_u8
		}
		.div {
			typ = .div_u8
		}
		.mod {
			typ = .mod_u8
		}
	}
	return Instruction{
		typ: typ
		operand_type: .uint8
		has_op: false
	}
}
