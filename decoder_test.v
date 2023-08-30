module decoder

fn test_decode_nop() {
	mut bytecode := []u8{}
	bytecode << 'VM'.bytes()
	bytecode << 0x0
	bytecode << 0x1
	bytecode << 0x0
	bytecode << 0x01
	decoder := decode(bytecode, 'dummy')
	assert decoder.program.len == 1
	assert decoder.program[0].typ == .plus_u8
	assert decoder.program[0].operand == 0
	assert decoder.program[0].has_op == false
}

fn test_decode_with_op() {
	mut bytecode := []u8{}
	bytecode << 'VM'.bytes()
	bytecode << 0x00
	bytecode << 0x01
	bytecode << 0x00
	bytecode << 0x00
	bytecode << 0x0A
	decoder := decode(bytecode, 'dummy')
	assert decoder.program.len == 1
	assert decoder.program[0].typ == .push_u8
	assert decoder.program[0].operand == 10
	assert decoder.program[0].has_op == true
}
