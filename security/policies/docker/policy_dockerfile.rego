package docker

import rego.v1

allow_list := {"python:3.13.17-slim-bookworm"}

instructions := [instruction |
	walk(input, [_, instruction])
	is_object(instruction)
	instruction.Cmd
]

final_stage_number := max({instruction.Stage |
	some instruction in instructions
	instruction.Cmd == "from"
})

final_stage := [instruction |
	some instruction in instructions
	instruction.Stage == final_stage_number
]

final_user := users[count(users) - 1] if {
	users := [instruction |
		some instruction in final_stage
		instruction.Cmd == "user"
		count(instruction.Value) > 0
		instruction.Value[0] != ""
	]
}

deny contains msg if {
	not final_user
	msg := "Estágio final do Dockerfile deve declarar USER"
}

deny contains msg if {
	user_parts := split(final_user.Value[0], ":")
	user := user_parts[0]
	user in {"root", "0"}
	msg := sprintf("Imagem Docker não deve executar como root (USER %s)", [final_user.Value[0]])
}

deny contains msg if {
	some instruction in instructions
	instruction.Cmd == "from"
	count(instruction.Value) > 0
	image := instruction.Value[0]
	not image in allow_list
	msg := sprintf("Imagem Docker não permitida: %s", [image])
}
