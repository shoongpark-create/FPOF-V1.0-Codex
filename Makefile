SHELL := /bin/bash

.PHONY: status sync-state sync-check route-skill check-output task-agent convert

status:
	./scripts/status.sh

sync-state:
	./scripts/sync-state.sh

sync-check:
	./scripts/sync-state.sh --check

route-skill:
	./scripts/route-skill.sh "$(PROMPT)"

check-output:
	./scripts/check-output.sh "$(INPUT)"

task-agent:
	./scripts/task-agent.sh $(AGENT) $(ARGS)

convert:
	./scripts/task-agent.sh format-converter --in "$(IN)" --out "$(OUT)"
