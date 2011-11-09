%{
#include "y.tab.h"
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
StringLiteral \"[^\\"]\"

Identifier  {Letter}({Letter}|{Digit})*
%%

{EverythingElse}    { return yytext[0]; }
"+"         { return ADD; }
"-"         { return SUBTRACT; }
"*"         { return MULTIPLY; }
"/"         { return DIVIDE; }
"class"     { return CLASS; }
"int"       { return INT; }
"void"      { return VOID; }
"public"    { return PUBLIC; }
"static"    { return STATIC; }
{Identifier}    { printf("\n\nIdentifier: %s\n\n", yytext); return IDENTIFIER; }
{Number}    { return CONSTANT; }
{StringLiteral} { return STRING; }
{Comment}       {}
{Whitespace}    {}

