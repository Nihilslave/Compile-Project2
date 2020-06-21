/****************************************************/
/* File: lex.l                                      */
/* Lex specification for Lex                        */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

%{

#include <cstdio>
#include "../../include/IR.h"
#define YYSTYPE Boost::Internal::Ref<const Boost::Internal::IRNode>
#include "y.tab.h"
#include "../../include/global.h"

%}
 

letter	    [A-Za-z_]
digit1	    [1-9]
digit2      [0-9]
IntV        {digit1}+{digit2}*
FloatV      {digit1}+{digit2}*\.{digit2}+
Id		    {letter}({letter}|{digit2})*
newline     (\n\r|\n)
whitespace  [ \t]+
commentline "//".*

%%
 
"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}
"//"            {return DOVER;}
"%"             {return MOD;}
"="             {return ASSIGN;}
"=="            {return yEQ;}
"!="            {return yNE;}
"<"             {return yLT;}
"<="	        {return yLE;}
">"             {return yGT;}
">="	        {return yGE;}
"["             {return LMIDB;}
"]"             {return RMIDB;}
"("             {return LPAREN;}
")"             {return RPAREN;}
";"             {return SEMI;}
","             {return COMMA;}
{Id}	        {return ID;}
{IntV}          {return INTV;}
{FloatV}        {return FLOATV;}
{newline}       {}
{commentline}   {}
{whitespace}    {/* printf("get space\n"); skip whitespace */} 
 
%%
int yywrap()
{
    return 1;
}

