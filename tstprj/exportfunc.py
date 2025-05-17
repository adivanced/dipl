wrapped_names = []
sysv_regs = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"]
sysv_preserved_regs = ["rbx", "rbp", "r12", "r13", "r14", "r15"]

def c_file_prelude(c_file):
	c_file.write("#include <stdint.h>\n\n")
	c_file.write("struct exportfunc{\n\n")

def c_file_epilogue(c_file):
	c_file.write("};\n")

def asm_data_file_prelude(asm_data):
	asm_data.write("exportfunc_data:\n")

def asm_file_epilogue(asm_file):
	asm_file.write("exportfunc_fill:\n")
	print(wrapped_names)
	for i in wrapped_names:
		asm_file.write("	" + "lea rax, [" + i + "]\n")
		asm_file.write("	" + "mov qword [" + i + "_wrapptr" + "], rax\n\n")
	asm_file.write("ret\n\n")




def proc_function(function_signature, c_file, asm_file, asm_data_file):
	func_c_sign = function_signature.replace("|", "_")
	tmp = func_c_sign.split("(")[0].split(" ")[-1]
	tmp = func_c_sign.replace(tmp, "(*"+ tmp + ")")

	arg_regs = []
	function_signature = function_signature.split(")")[0]
	for i in function_signature.split():
		if "|" not in i:
			continue
		else:
			arg_regs.append(i.split("|")[1])

	print(func_c_sign)
	print(arg_regs)

	c_file.write("	" + tmp)

	function_name = func_c_sign.split("(")[0].split()[-1]
	
	asm_data_file.write("	" + function_name+"_wrapper_wrapptr"+" dq 0\n")

	asm_file.write(function_name+"_wrapper:\n")
	for i in range(0, len(sysv_preserved_regs)):
		asm_file.write("	push " + sysv_preserved_regs[i] + "\n")
	for i in range(len(arg_regs)-1, -1, -1):
		#asm_file.write("	" + "mov " + arg_regs[i].replace(",", '') + ", " + sysv_regs[i] + "\n")
		asm_file.write("	push " + sysv_regs[i] + "\n");
	for i in range(0, len(arg_regs)):
		asm_file.write("	pop " + arg_regs[i].replace(",", '') + "\n")

	asm_file.write("	call " + function_name + "\n\n")
	for i in range(len(sysv_preserved_regs)-1, -1, -1):
		asm_file.write("	pop " + sysv_preserved_regs[i] + "\n")
	asm_file.write("ret\n")
	wrapped_names.append(function_name+"_wrapper")


def proc_variable(variable, c_file, asm_file, asm_data_file):
	c_file.write("	" + variable)
	variable = variable.replace(";", '')
	var_name = variable.split()[1]
	asm_data_file.write("	" + var_name + "_wrapptr" + " dq 0\n\n")
	wrapped_names.append(var_name)



asm_wrappers_inc = open("exportfunc.inc", "w")
asm_wrappers_data = open("exportfunc_data.inc", "w")
c_header = open("exportfunc.h", "w")



c_file_prelude(c_header)
asm_data_file_prelude(asm_wrappers_data)

with open("exportfunc.txt") as exportfunc_txt:
	for line in exportfunc_txt:
		if(len(line) > 5):
			if line[-3] == ")":
				proc_function(line, c_header, asm_wrappers_inc, asm_wrappers_data)
			else:
				proc_variable(line, c_header, asm_wrappers_inc, asm_wrappers_data)			


c_file_epilogue(c_header)
asm_file_epilogue(asm_wrappers_inc)
