# Atajos del meta-repo hijo: cada target llama a ./pj. Lo manda robert-flo/pj-template
# (plantillas/hijo/Makefile); no lo edités en el hijo (./pj check lo compara).
# Para actualizar antes de abrir un agente: make listo a-pm  /  make listo c-pm
# Argumentos extra: make a-pm ARGS="--print hola"  /  make c-pm ARGS="…"
.DEFAULT_GOAL := help
.PHONY: help a-pm a-wk a-rv a-os c-pm c-wk c-rv c-os listo onboard sync check clean fleet watch

help:
	@awk 'BEGIN {FS = ":.*## "} /^##@/ {if (n++) printf "\n"; printf "%s\n", substr($$0, 5)} /^[a-z0-9-]+:.*## / {printf "  %-9s %s\n", $$1, $$2}' $(firstword $(MAKEFILE_LIST))

##@ Agentes — agy
a-pm: ## Abre el PM en agy al instante (--solo, sin pull ni listo)
	@./pj agy pm --solo $(ARGS)
a-wk: ## Abre el WK en agy al instante (--solo, sin pull ni listo)
	@./pj agy wk --solo $(ARGS)
a-rv: ## Abre el RV en agy al instante (--solo, sin pull ni listo)
	@./pj agy rv --solo $(ARGS)
a-os: ## Abre el OS (oneshot) en agy al instante (--solo, sin pull ni listo)
	@./pj agy os --solo $(ARGS)

##@ Agentes — Cursor
c-pm: ## Abre el PM en Cursor al instante (--solo, sin pull ni listo)
	@./pj cursor pm --solo $(ARGS)
c-wk: ## Abre el WK en Cursor al instante (--solo, sin pull ni listo)
	@./pj cursor wk --solo $(ARGS)
c-rv: ## Abre el RV en Cursor al instante (--solo, sin pull ni listo)
	@./pj cursor rv --solo $(ARGS)
c-os: ## Abre el OS (oneshot) en Cursor al instante (--solo, sin pull ni listo)
	@./pj cursor os --solo $(ARGS)

##@ Home Repo
listo: ## git pull + template + genera + hooks + enlaces de agy + clona + check
	@./pj listo $(ARGS)
onboard: ## Entrevista del PM (onboarding.yml); idempotente
	@./pj onboard $(ARGS)
sync: ## Actualiza template_ref al último main de pj-template, copia el molde y corre ./pj check
	@./pj sync $(ARGS)
check: ## Corre ./pj check sobre el meta-repo hijo
	@./pj check
clean: ## Deshace ./pj listo (ARGS=--onboarding: también el onboarding)
	@./pj clean $(ARGS)

##@ Flota (pj-trio)
fleet: ## Estado de la flota pj-trio (ARGS=--activos, --json)
	@pj-trio fleet . $(ARGS)
watch: ## Observa .trio (ARGS=--ticket …, --timeout …)
	@pj-trio watch . $(ARGS)
