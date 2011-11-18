%{
#include "y.tab.h"
#include <string.h>
%}

%option noyywrap

EverythingElse  [{}\(\);,=]
Comment1    [\/][\*]([^\*]*|[\*][^\/])*[\*][\/]
Comment2    [\/][\/].*
Comment     ({Comment1}|{Comment2})
Whitespace  [ \t\r\n]

Digit   [0-9]
Number  {Digit}+
Letter  [a-zA-Z_.]
StringLiteral \"([^\"]+)\"

Identifier  {Letter}({Letter}|{Digit})*
%%

{EverythingElse}    { return yytext[0]; }
"+"         { return ADD; }
"-"         { return SUBTRACT; }
"*"         { return MULTIPLY; }
"/"         { return DIVIDE; }
"public"    {}
"static"    {}
"class"     { return CLASS; }
"int"       { return INT; }
"void"      { return VOID; }
"String[]"  { return STRINGARRAY; }
{StringLiteral} { yylval = strdup((char *)(yytext+1)); ((char *)yylval)[yyleng-2] = '\0'; return STRING; }
{Identifier}    { yylval = strdup((char *)yytext); return IDENTIFIER; }
{Number}    { yylval = atoi(yytext); return CONSTANT; }
{Comment}       {}
{Whitespace}    {}
