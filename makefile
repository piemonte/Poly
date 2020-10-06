# setup pods
setup-pods:
	@echo [installing cocoapods]
	@sudo /usr/bin/gem install -n /usr/local/bin cocoapods --pre
	@pod repo update
	@pod setup

install-pods:
	@echo [installing pods]
	@-rm Podfile.lock
	@-rm -rf ./Pods
	@pod install

clean-pods:
	@echo [removing local Pods caches]
	@echo /Users/$$USER/.cocoapods/*
	@echo ensure to re-run make setup!
	@-rm -rf /Users/$$USER/.cocoapods/*

.PHONY: setup-pods install-pods clean-pods 
