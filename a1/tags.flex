/*
  File Name: tiny.flex
  JFlex specification for the TINY language
*/

import java.util.ArrayList;

%%

%class Lexer
%type Token
%line
%column

%eofval{
  //System.out.println("*** end of file reached");
  return null;
%eofval};

%{
  private static ArrayList<String> tagStack = new ArrayList<String>();
  private static String[] irreleventTags = { "Byline", "Correction", "Correction-Date", "Dateline", "DocID", "Graphic", "Section", "Subject", "Type" };
  /**
  * Returns the tag name of a passed-in tag for displaying purposes.
  * @param tag The tag to get the name of.
  * @return the name of the tag.
  **/
  private String getTagName(String tag) {
    tag = tag.replace("<", "");
    tag = tag.replace(">", "");
    tag = tag.replace("/", "");
    String[] splits = tag.split(" ");
    if (splits.length > 1){
      return splits[0];
    } else {
      return splits[0];
    }
  }

  private void push(String tag) {
    tagStack.add(0, tag);
  }

  private String peek() {
    if (tagStack.size() > 0) {
      return tagStack.get(0);
    }
    else {
      return null;
    }
  }

  private void pop() {
    tagStack.remove(0);
  }

  private Boolean checkClosingTag(String tag) {
    tag = tag.replace("/", "");
    if (!getTagName(tag).equals(peek())){
      System.out.println("ERROR Tag mismatch. " + tag + " does not have a matching opening tag.");
      return false;
    }
    return true;
  }

  private void printStack() {
    for(String s : tagStack) {
      System.out.println(s);
    }
  }

  private Boolean containsIrrelevantTags() {
    for (String tag : tagStack) {
      for (String s : irreleventTags) {
        if (tag.equals(s)) {
          return true;
        }
      }
    }
    return false;
  }

  private Boolean isIrrelevantTag(String tag) {
    for (String s : irreleventTags) {
      if (tag.equals(s)) {
        return true;
      }
    }
    return false;
  }
%};


/* A line terminator is a \r (carriage return), \n (line feed), or
   \r\n. */
LineTerminator = \r|\n|\r\n

/* White space is a line terminator, space, tab, or form feed. */
WhiteSpace     = {LineTerminator} | [ \t\f]
digit = [0-9]
number = [-]*{digit}+ | ([-]*{digit}+.{digit}+)
tagPunctuation = [=\-'\"]
puncutation = [-()*\\:;\"\'?\/.>,<]*
letter = [a-zA-Z]
word = [a-zA-Z0-9]+
apostrophized  = ({letter}+\'{letter}*)+
attribute = [a-zA-Z0-9\"= ]
hyphenated = ({word}-{word}*)+
OpeningBrace = <
ClosingBrace = >
openTag = {OpeningBrace}" "*{word}+{attribute}*{ClosingBrace}
closeTag = {OpeningBrace}"/"{word}+{ClosingBrace}


%%


 // This section contains regular expressions and actions, i.e. Java
 // code, that will be executed when the scanner matches the associated
 // regular expression.

{openTag}       {
                  String tag = getTagName(yytext());
                  push(tag);
                  if (tag.toUpperCase().equals("P") && !containsIrrelevantTags()) {
                    return new Token(Token.OPENTAG, getTagName(yytext()), yyline, yycolumn);
                  } else if (!isIrrelevantTag(tag) && !tag.toUpperCase().equals("P")) {
                    return new Token(Token.OPENTAG, getTagName(yytext()), yyline, yycolumn);
                  }
                }
{closeTag}      {
                  String tag = getTagName(yytext());
                  if (checkClosingTag(yytext())) {
                    pop();
                    if ((!tag.toUpperCase().equals("P") && !containsIrrelevantTags()) && !isIrrelevantTag(getTagName(tag))) {
                      return new Token(Token.CLOSETAG, getTagName(yytext()), yyline, yycolumn);
                    } else if (tag.toUpperCase().equals("P") && !containsIrrelevantTags()) {
                      return new Token(Token.CLOSETAG, getTagName(yytext()), yyline, yycolumn);
                    }
                  }
                }
{hyphenated}    {
                  if (!isIrrelevantTag(peek())) {
                    return new Token(Token.HYPHENATED, yytext(), yyline, yycolumn);
                  }
                }
{puncutation}   {
                  if (!isIrrelevantTag(peek())) {
                    return new Token(Token.PUNCTUATION, yytext(), yyline, yycolumn);
                  }
                }
{apostrophized} {
                  if (!isIrrelevantTag(peek())) {
                    return new Token(Token.APOSTROPHIZED, yytext(), yyline, yycolumn);
                  }
                }
{number}        {
                  if (!isIrrelevantTag(peek())) {
                    return new Token(Token.NUMBER, yytext(), yyline, yycolumn);
                  }
                }
{word}          {
                  if (!isIrrelevantTag(peek()) && !containsIrrelevantTags()) {
                    return new Token(Token.WORD, yytext(), yyline, yycolumn);
                  }
                }
{WhiteSpace}    {}
.               { return new Token(Token.ERROR, yytext(), yyline, yycolumn); }
