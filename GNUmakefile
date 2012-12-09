# SVT Makefile                                                                                                                                                            
.PHONY: all deps check test eunit test clean

all: deps compile

compile:
	./rebar compile

deps:
	./rebar get-deps

docs:
	./rebar doc

rel: all
	./rebar generate

test:   all
	eunit ct

ct: all
	./rebar ct

eunit: all
	./rebar eunit

shell: all
	erl -sname rett -pa $(PWD)/lib/*/ebin -boot start_sasl -config rel/files/sys.config  -s reloader -s rett_app

conf_clean:
        @:

clean:
	./rebar clean
	$(RM) doc/*

# eof
