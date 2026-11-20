# Atajos del meta-repo hijo: cada target llama a ./pj. Lo manda robert-flo/pj-template
# (plantillas/hijo/Makefile); no lo edités en el hijo (./pj check lo compara).
# Argumentos extra: make agy-pm ARGS="--print hola"
.DEFAULT_GOAL := help
.PHONY: help pm os agy-pm agy-wk agy-rv agy-os listo onboard clean sync check
help:   ## Lista los atajos
	@grep -E '^[a-z-]+:.*## ' $(firstword $(MAKEFILE_LIST)) | sed -E 's/:.*## /\t/'
pm:     ## Abre el PM al instante sin re-correr pull ni listo (rápido)
	@./pj agy pm --solo $(ARGS)
os:     ## Abre el rol OS (oneshot) al instante sin re-correr pull ni listo
	@./pj agy os --solo $(ARGS)
agy-pm: ## git pull + ./pj listo y abre el PM en agy (mise, --dangerously-skip-permissions)
	@./pj agy pm $(ARGS)
agy-wk: ## Igual, con el WK
	@./pj agy wk $(ARGS)
agy-rv: ## Igual, con el RV
	@./pj agy rv $(ARGS)
agy-os: ## Igual, con el OS (oneshot)
	@./pj agy os $(ARGS)
listo:  ## git pull + template + genera + hooks + enlaces de agy + clona + check
	@./pj listo $(ARGS)
onboard: ## Entrevista del PM (onboarding.yml); idempotente
	@./pj onboard $(ARGS)
clean:  ## Deshace ./pj listo (ARGS=--onboarding: también el onboarding)
	@./pj clean $(ARGS)
sync:   ## Actualiza template_ref al último main de pj-template, copia el molde y corre ./pj check
	@./pj sync $(ARGS)
check:  ## ./pj check
	@./pj check
