all: oralibcurl.so

oralibcurl.so: oralibcurl.c
	gcc -shared -o oralibcurl.so -fPIC -Wall -I$(ORACLE_HOME)/rdbms/public -lcurl -L$(ORACLE_HOME)/lib/ -L$(ORACLE_HOME)/rdbms/lib/ oralibcurl.c

clean:
	rm -f oralibcurl.so

