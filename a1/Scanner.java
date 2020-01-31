/**
* CIS*4650 Warmup Assignment - Tagged Document Tokenizer
* Christian Cornelis
* ccorneli@uoguelph.ca
* S/N: 0939357
* January 30th, 2020
*
* Scanner class that tokenizes input from STDIN
**/
import java.io.InputStreamReader;

public class Scanner {
  private Lexer scanner = null;

  public Scanner( Lexer lexer ) {
    scanner = lexer;
  }

  public Token getNextToken() throws java.io.IOException {
    return scanner.yylex();
  }

  public static void main(String argv[]) {
    try {
      Scanner scanner = new Scanner(new Lexer(new InputStreamReader(System.in)));
      Token tok = null;
      while( (tok=scanner.getNextToken()) != null )
        System.out.println(tok);
    }
    catch (Exception e) {
      System.out.println("Unexpected exception:");
      e.printStackTrace();
    }
  }
}
