package docker

test_deny_when_final_stage_has_no_user if {
	count(deny) with input as [[{"Cmd": "from", "Stage": 0, "Value": ["python:3.13.17-slim"]}]] == 1
}

test_deny_when_final_user_is_root if {
	count(deny) with input as [[
		{"Cmd": "from", "Stage": 0, "Value": ["python:3.13.17-slim"]},
		{"Cmd": "user", "Stage": 0, "Value": ["root"]},
	]] == 1
}

test_deny_when_final_user_is_zero if {
	count(deny) with input as [[
		{"Cmd": "from", "Stage": 0, "Value": ["python:3.13.17-slim"]},
		{"Cmd": "user", "Stage": 0, "Value": ["0:0"]},
	]] == 1
}

test_allow_non_root_final_user if {
	count(deny) with input as [[
		{"Cmd": "from", "Stage": 0, "Value": ["python:3.13.17-slim"]},
		{"Cmd": "user", "Stage": 0, "Value": ["appuser"]},
	]] == 0
}

test_only_final_stage_user_is_checked if {
	count(deny) with input as [
		[
			{"Cmd": "from", "Stage": 0, "Value": ["python:3.13.17-slim"]},
		],
		[
			{"Cmd": "from", "Stage": 1, "Value": ["python:3.13.17-slim"]},
			{"Cmd": "user", "Stage": 1, "Value": ["appuser"]},
		],
	] == 0
}

test_deny_when_image_is_not_in_allow_list if {
	count(deny) with input as [[
		{"Cmd": "from", "Stage": 0, "Value": ["alpine"]},
		{"Cmd": "user", "Stage": 0, "Value": ["appuser"]},
	]] == 1
}

test_deny_unapproved_image_in_any_stage if {
	count(deny) with input as [[
		{"Cmd": "from", "Stage": 0, "Value": ["alpine"], "Flags": null},
		{"Cmd": "from", "Stage": 1, "Value": ["python:3.13.17-slim"], "Flags": null},
		{"Cmd": "user", "Stage": 1, "Value": ["appuser"]},
	]] == 1
}
