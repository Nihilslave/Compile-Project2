/****************************************************/
/* File: yacc.y                                     */
/* The YACC Yacc/Bison specification file           */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include <cstdio>
#include <cstdlib>
#include <ctype.h>
#include <string.h>
#include <typeinfo>
#include <map>
#include "lex.yy.c"
#include "../../include/IR.h"

using namespace std;
using namespace Boost::Internal;


//extern Boost::Internal::Ref<const Boost::Internal::IRNode> TreeRoot; /* save IR tree here */
extern YYSTYPE TreeRoot; /* save IR tree here */


void yyerror(const char*);
//int yylex(void);
%}

%token ID INTV FLOATV
%token ASSIGN yEQ yNE yLT yLE yGT yGE PLUS MINUS TIMES OVER DOVER MOD SEMI COMMA LBRACE RBRACE LMIDB RMIDB LPAREN RPAREN

%left ADD MINUS
%left TIMES OVER DOVER MOD
%nonassoc ASSIGN

%start program

%%

program
	: P
	{
		printf("TreeRoot Construted! \n");
		TreeRoot = $$ = $1;
		
	}
	;

P
	: P S
	{
		printf("P S\n");

		std::shared_ptr<Move> ptr_s = std::const_pointer_cast<Move>(std::dynamic_pointer_cast<const Move>($2.real_ptr()));
    	std::shared_ptr<Kernel> kernel_ans = std::const_pointer_cast<Kernel>(std::dynamic_pointer_cast<const Kernel>($1.real_ptr()));
    	kernel_ans->stmt_list.push_back(Stmt(ptr_s));
		$$ = YYSTYPE(kernel_ans);
		
	}
	| S
	{

		printf("S\n");
		
		std::shared_ptr<Move> ptr_s = std::const_pointer_cast<Move>(std::dynamic_pointer_cast<const Move>($1.real_ptr()));
		// init a kernel!
    	std::shared_ptr<Kernel> kernel_ans = std::make_shared<Kernel>("kernal", std::vector<Expr>(), std::vector<Expr>(), std::vector<Stmt>(), KernelType::CPU);
    	kernel_ans->stmt_list.push_back(Stmt(ptr_s));

		$$ = YYSTYPE(kernel_ans);
		
	}
	;


S
	: LHS ASSIGN RHS SEMI
	{

		printf("LHS ASSIGN RHS SEMI  L = R \n");	
		Expr ptr_left = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
    	Expr prt_right = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));

    	std::shared_ptr<Move> tmp_ptr = std::make_shared<Move>(ptr_left, prt_right, MoveType::MemToMem);
		$$ = YYSTYPE(tmp_ptr);

	}
	;

LHS
	: TRef
	{
		$$ = $1;
	}
	;

RHS
	: RHS PLUS RHS
	{	

		printf("RHS PLUS RHS \n");
		
		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
   		Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Add, ptr1, ptr2);
		$$ = YYSTYPE(tmp_ptr);
		
	}
	| RHS TIMES RHS
	{
		
		printf("RHS Times RHS \n");
		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
   		Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Mul, ptr1, ptr2);
		
		$$ = YYSTYPE(tmp_ptr);
		
	}
	| RHS MINUS RHS
	{
		
		printf("RHS MINUS RHS \n");
		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
   		Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Sub, ptr1, ptr2);
		$$ = YYSTYPE(tmp_ptr);
		
	}
	| RHS OVER RHS
	{
		
		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
   		Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Div, ptr1, ptr2);
		$$ = YYSTYPE(tmp_ptr);
		
	}
	| RHS MOD RHS
	{
		
		printf("RHS MOD RHS \n");
		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
   		Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Mod, ptr1, ptr2);
		$$ = YYSTYPE(tmp_ptr);
	}
	| RHS DOVER RHS
	{
		
		printf("RHS DOVER RHS \n");
		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
   		Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::DDiv, ptr1, ptr2);
		$$ = YYSTYPE(tmp_ptr);
		
	}
	| LPAREN RHS RPAREN
	{
		auto child_t = $2.real_ptr();
   		$$ = YYSTYPE(make_shared<Unary>(Type::float_scalar(32), UnaryOpType::Paren, Expr(dynamic_pointer_cast<const ExprNode>(child_t))));
	}
	| TRef
	{
		$$ = $1;
	}
	| SRef
	{
		$$ = $1;
	}
	| CConst
	{
		$$ = $1;
	}
	;

TRef
	: Id yLT CList yGT LMIDB AList RMIDB
	{

		printf("AList: Id yLT CList yGT LMIDB AList RMIDB \n");

		std::shared_ptr<StringImm> name_ptr = const_pointer_cast<StringImm>(dynamic_pointer_cast<const StringImm>($1.real_ptr()));
		std::shared_ptr<Var> Clist_P = const_pointer_cast<Var>(dynamic_pointer_cast<const Var>($3.real_ptr()));
		
		std::shared_ptr<Var> ptr_A = const_pointer_cast<Var>(dynamic_pointer_cast<const Var>($6.real_ptr()));
		auto Tref_P = make_shared<Var>(Type::float_scalar(32), name_ptr->value(), ptr_A->args, Clist_P->shape);
	    
		// add to global index_list map
		// used by printer
		for(int i = 0; i < Tref_P->args.size(); ++i)
		{
			if(typeid(*(Tref_P->args[i])) == typeid(StringImm))
			{
				auto Idx_name = const_pointer_cast<StringImm>(dynamic_pointer_cast<const StringImm>(Tref_P->args[i].real_ptr()));
				if(indexlist.find(Idx_name->value()) == indexlist.end())
				{
					indexlist.insert(pair<string, size_t>(Idx_name->value(), Clist_P->shape[i]));
				}
				else
				{
					
					if(Clist_P->shape[i] < indexlist[Idx_name->value()])
					{
						indexlist.insert(pair<string, size_t>(Idx_name->value(), Clist_P->shape[i]));
					}
				}
			}
			
		}
		varlist.insert(pair<string, vector<size_t> >(name_ptr->value(), Clist_P->shape));
		$$ = YYSTYPE(Tref_P);
	}
	;

SRef
	: Id yLT CList yGT
	{
		
		std::shared_ptr<Var> Clist_P = const_pointer_cast<Var>(dynamic_pointer_cast<const Var>($3.real_ptr()));
		std::shared_ptr<StringImm> Id_P = const_pointer_cast<StringImm>(dynamic_pointer_cast<const StringImm>($1.real_ptr()));
		std::shared_ptr<Var>  Sref_P = make_shared<Var>(Type::float_scalar(32), Id_P->value(), vector<Expr>(), Clist_P->shape);
	    varlist.insert(pair<string, vector<size_t> >(Id_P->value(), Clist_P->shape));
		$$ = YYSTYPE(Sref_P);
	}
	;

CList
	: CList COMMA IINT
	{
		

		std::shared_ptr<Var> tmp_ptr = std::const_pointer_cast<Var>(std::dynamic_pointer_cast<const Var>($1.real_ptr()));
		std::shared_ptr<const IntImm> int_var_ptr = std::dynamic_pointer_cast<const IntImm>($3.real_ptr());
    	tmp_ptr->shape.push_back(int_var_ptr->value());
		$$ = YYSTYPE(tmp_ptr);
		cout << "CLIST Last INT " << int_var_ptr->value() << " >" << endl;
	}
	| IINT
	{
		

		std::shared_ptr<Var> tmp_ptr = std::make_shared<Var>(Type::int_scalar(32), "", std::vector<Expr>(), std::vector<size_t>());
    	std::shared_ptr<const IntImm> int_var_ptr = std::dynamic_pointer_cast<const IntImm>($1.real_ptr());
    	tmp_ptr->shape.push_back(int_var_ptr->value());
		$$ = YYSTYPE(tmp_ptr);
		cout << "CList INT < " << int_var_ptr->value() << endl;
	}
	;

AList
	: AList COMMA IdExpr
	{

	    std::shared_ptr<Boost::Internal::Var> tmp_ptr = std::const_pointer_cast<Boost::Internal::Var>(std::dynamic_pointer_cast<const Boost::Internal::Var>($1.real_ptr()));
    	std::shared_ptr<const Boost::Internal::ExprNode> id_expr_ptr = std::dynamic_pointer_cast<const Boost::Internal::ExprNode>($3.real_ptr());
    	tmp_ptr->args.push_back(Expr(id_expr_ptr));
    	
		$$ = YYSTYPE(tmp_ptr);

	}
	| IdExpr
	{
		
		std::shared_ptr<Var> tmp_ptr = std::make_shared<Boost::Internal::Var>(Type::int_scalar(32), "", std::vector<Expr>(), std::vector<size_t>());
    	std::shared_ptr<const ExprNode> id_expr_ptr = std::dynamic_pointer_cast<const Boost::Internal::ExprNode>($1.real_ptr());
    	tmp_ptr->args.push_back(Expr(id_expr_ptr));
    	
		$$ = YYSTYPE(tmp_ptr);
	}
	;

IdExpr
	: Id
	{
		$$ = $1;
	}
	| IdExpr PLUS IdExpr
	{
		

		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
    	Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Add, ptr1, ptr2);
		$$ = tmp_ptr;
	}
	| IdExpr PLUS IINT
	{
		

		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
    	Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Add, ptr1, ptr2);
		$$ = tmp_ptr;
	}
	| IdExpr MINUS IINT
	{
		

		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
    	Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Sub, ptr1, ptr2);
		$$ = tmp_ptr;
	}
	| IdExpr TIMES IINT
	{
		

		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
    	Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Mul, ptr1, ptr2);
		$$ = tmp_ptr;
	}
	| IdExpr DOVER IINT
	{
		
		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
    	Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Div, ptr1, ptr2);
		$$ = tmp_ptr;
	}
	| IdExpr MOD IINT
	{
		

		Expr ptr1 = Expr(std::dynamic_pointer_cast<const ExprNode>($1.real_ptr()));
    	Expr ptr2 = Expr(std::dynamic_pointer_cast<const ExprNode>($3.real_ptr()));
    	std::shared_ptr<Binary> tmp_ptr = std::make_shared<Binary>(Type::float_scalar(32), BinaryOpType::Mod,  ptr1, ptr2);
		$$ = tmp_ptr;
	}
	;

Id
	: ID
	{
		$$ = StringImm::make(data_type, yytext);
		printf("%s\n", yytext);
	}
	;

CConst
	: FFLOAT
	{
		$$ = $1;
	}
	| IINT
	{
		$$ = $1;
	}
	;

FFLOAT
	: FLOATV
	{
		$$ = FloatImm::make(data_type, atof(yytext));
		printf("FloatV %s\n", yytext);

	};

IINT
	: INTV
	{
		$$ = IntImm::make(data_type, atoi(yytext));
		printf("IntV %s\n", yytext);
	};


%%

void yyerror(const char * s)
{
  printf("error\n");
}



void yy_input_string(char* str)
{
yy_switch_to_buffer(yy_scan_string(str));
}


