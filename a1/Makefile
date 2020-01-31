JAVAC=javac
JFLEX=jflex

all: Token.class Lexer.class Scanner.class

%.class: %.java
	$(JAVAC) $^

Lexer.java: tags.flex
	$(JFLEX) tags.flex

clean:
	rm -f Lexer.java *.class *~
