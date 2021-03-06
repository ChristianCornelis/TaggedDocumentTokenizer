/**
* CIS*4650 Warmup Assignment - Tagged Document Tokenizer
* Christian Cornelis
* ccorneli@uoguelph.ca
* S/N: 0939357
* January 30th, 2020
*
* Token class representing a matched token from the lexer.
**/
class Token {

 //Token type definitions
  public final static int ERROR = 0;
  public final static int OPENTAG = 1;
  public final static int CLOSETAG = 2;
  public final static int WORD = 3;
  public final static int NUMBER = 4;
  public final static int APOSTROPHIZED = 5;
  public final static int HYPHENATED = 6;
  public final static int PUNCTUATION = 7;

  public int m_type;
  public String m_value;
  public int m_line;
  public int m_column;

  Token (int type, String value, int line, int column) {
    m_type = type;
    m_value = value;
    m_line = line;
    m_column = column;
  }

  /**
  * Yields a string of the token description.
  * @return the string containing the description of the token
  **/
  public String toString() {
    switch (m_type) {
      case OPENTAG:
        return "OPEN-" + m_value.toUpperCase();
      case CLOSETAG:
        return "CLOSE-" + m_value.toUpperCase();
      case WORD:
        return "WORD(" + m_value + ")";
      case NUMBER:
        return "NUMBER(" + m_value + ")";
      case APOSTROPHIZED:
        return "APOSTROPHIZED(" + m_value + ")";
      case HYPHENATED:
        return "HYPHENATED(" + m_value + ")";
      case PUNCTUATION:
        return "PUNCTUATION(" + m_value + ")";
      default:
        return "UNKNOWN(" + m_value + ")";
    }
  }
}
