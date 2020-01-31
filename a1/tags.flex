/**
* CIS*4650 Warmup Assignment - Tagged Document Tokenizer
* Christian Cornelis
* ccorneli@uoguelph.ca
* S/N: 0939357
* January 30th, 2020
* JFlex specification for the SGML language
*/

import java.util.ArrayList;

%%

%class Lexer
%type Token
%line
%column

%{
  //declare global stack and literal string array of tags to be ignored.
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
    tag = tag.trim();
    String[] splits = tag.split(" ");
    return splits[0];
  }

  /**
  * Pushes a tag to the top of the stack
  * @param tag The tag to push to the stack
  **/
  private void push(String tag) {
    tagStack.add(0, tag);
  }

  /**
  * Peeks at the tag at the top of the stack and returns it.
  * @return The tag if the stack is not empty. Null if the stack is empty.
  **/
  private String peek() {
    if (tagStack.size() > 0) {
      return tagStack.get(0);
    }
    else {
      return null;
    }
  }

  /**
  * Pops the element at the top of the stack
  **/
  private void pop() {
    tagStack.remove(0);
  }

  /**
  * Checks that the case-insensitive closing tag has a matching opening tag at the top of the stack.
  * Displays an error if they do not.
  * @param tag The tag to check for a matching opening tag
  * @return Boolean representing if the tag has a matching opening tag on the top of the stack
  **/
  private Boolean checkClosingTag(String tag) {
    String tag_cpy = tag.replace("/", "");
    if (!getTagName(tag_cpy.toUpperCase()).equals(peek().toUpperCase())){
      System.err.println("ERROR Tag mismatch. " + tag + " does not have a matching opening tag.");
      return false;
    }
    return true;
  }

  /**
  * Prints the entire global stack.
  * Used for debugging purposes and to show any tags left when the end of the file is reached.
  **/
  private void printStack() {
    for(String s : tagStack) {
      System.err.println(s);
    }
  }

  /**
  * Checks if the stack contains any irrelevent tags.
  * If the stack does, then we do not want to output any <p> tags.
  * @return a Boolean representing if the stack contains any irrelevent tags.
  **/
  private Boolean containsIrrelevantTags() {
    for (String tag : tagStack) {
      for (String s : irreleventTags) {
        if (tag.toUpperCase().equals(s.toUpperCase())) {
          return true;
        }
      }
    }
    return false;
  }

  /**
  * Checks if a tag is irrelevent
  * @param tag the tag to check
  * @return Boolean representing if the tag is irrelevent
  **/
  private Boolean isIrrelevantTag(String tag) {
    // case for text outside of a tag - treat as an irrelevant tag.
    if (tag == null) {
      return true;
    };
    for (String s : irreleventTags) {
      if (tag.toUpperCase().equals(s.toUpperCase())) {
        return true;
      }
    }
    return false;
  }

%};
%eofval{
  //If the stack is not empty when EOF is reached report an error and show all tags leftover.
  if (!tagStack.isEmpty()) {
    System.err.println("ERROR Tag stack not empty at end of file. Opening tags contained at EOF are:");
    printStack();
  }
  return null;
%eofval};

//A line terminator is a \r (carriage return), \n (line feed), or \r\n.
LineTerminator = \r|\n|\r\n
// White space is a line terminator, space, tab, or form feed.
WhiteSpace     = {LineTerminator} | [ \t\f]
digit = [0-9]
// Numbers can be digits preceded by a + or -  (or neither), or digits
// preceded by a +, -, or neither, followed by a decimal and more digits.
number = ("+"|"-"){digit}+ | (("+"|"-"){digit}+.{digit}+) | {digit}+ | ({digit}+.{digit}+)
punctuation = [-()*\\:;\"\'?\/.,\!\+]
// Words can contain letters and numbers
word = [a-zA-Z0-9]+
// Apostrophised words can be chained together, or can be hyphenated words that contain at least one apostrophe
apostrophized  = {word}(\'{word})+ | {word}(("-"{word})*("\'"{word})+("-"{word}*))+ | {word}(("-"{word})*"\'"{word})
// An attribute can contain letters, numbers, quotes, periods, and colons to account for HTML-esque attributes.
attribute = [a-zA-Z0-9\"=.: ]
hyphenated = {word}(-{word})+
OpeningBrace = <
ClosingBrace = >
openTag = {OpeningBrace}" "*({word}[-]*)+" "*{attribute}* " "*{ClosingBrace}
closeTag = {OpeningBrace}"/"" "*({word}[-]*)+" "*{ClosingBrace}


%%


 // This section contains regular expressions and actions.

{openTag}       {
                  String tag = getTagName(yytext());
                  // push tag to top of stack
                  push(tag);
                  // if the tag is relevant AND we aren't inside an irrelevant tag
                  if (!containsIrrelevantTags() && !isIrrelevantTag(tag)) {
                    return new Token(Token.OPENTAG, getTagName(yytext()), yyline, yycolumn);
                  }
                }
{closeTag}      {
                  String tag = getTagName(yytext());
                  // check that the opening tag at the top of the stack matches the current closing tag
                  // and pop the top element of the stack if they do, otherwise, an error is displayed.
                  if (checkClosingTag(yytext())) {
                    pop();
                    //if the tag is relevant AND we aren't inside an irrelevant tag
                    if (!containsIrrelevantTags() && !isIrrelevantTag(tag)) {
                      return new Token(Token.CLOSETAG, getTagName(yytext()), yyline, yycolumn);
                    }
                  }
                }
{number}        {
                  //if the parent tag is relevant and the stack contains no irrelevant tags
                  if (!isIrrelevantTag(peek()) && !containsIrrelevantTags()) {
                    return new Token(Token.NUMBER, yytext(), yyline, yycolumn);
                  }
                }
{hyphenated}    {
                  if (!isIrrelevantTag(peek()) && !containsIrrelevantTags()) {
                    return new Token(Token.HYPHENATED, yytext(), yyline, yycolumn);
                  }
                }
{word}          {
                  if (!isIrrelevantTag(peek()) && !containsIrrelevantTags()) {
                    return new Token(Token.WORD, yytext(), yyline, yycolumn);
                  }
              }
{punctuation}   {
                  if (!isIrrelevantTag(peek()) && !containsIrrelevantTags()) {
                    return new Token(Token.PUNCTUATION, yytext(), yyline, yycolumn);
                  }
                }
{apostrophized} {
                  if (!isIrrelevantTag(peek()) && !containsIrrelevantTags()) {
                    return new Token(Token.APOSTROPHIZED, yytext(), yyline, yycolumn);
                  }
                }
{WhiteSpace}    {}
.               { return new Token(Token.ERROR, yytext(), yyline, yycolumn); }
