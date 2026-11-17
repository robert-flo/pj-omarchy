# Atajos del meta-repo hijo: cada target llama a ./pj. Lo manda robert-flo/pj-template
# (plantillas/hijo/Makefile); no lo edités en el hijo (./pj check lo compara).
# Argumentos extra: make agy-pm ARGS="--print hola"
.DEFAULT_GOAL := help
.PHONY: help agy-pm agy-wk agy-rv listo onboard clean check
help:   ## Lista los atajos
	@grep -E '^[a-z-]+:.*## ' $(firstword $(MAKEFILE_LIST)) | sed -E 's/:.*## /\t/'
agy-pm: ## git pull + ./pj listo y abre el PM en agy (mise, --dangerously-skip-permissions)
	@./pj agy pm $(ARGS)
agy-wk: ## Igual, con el WK
	@./pj agy wk $(ARGS)
agy-rv: ## Igual, con el RV
	@./pj agy rv $(ARGS)
listo:  ## git pull + template + genera + hooks + enlaces de agy + clona + check
	@./pj listo $(ARGS)
onboard: ## Entrevista del PM (onboarding.yml); idempotente
	@./pj onboard $(ARGS)
clean:  ## Deshace ./pj listo (ARGS=--onboarding: también el onboarding)
	@./pj clean $(ARGS)
check:  ## ./pj check
	@./pj check
