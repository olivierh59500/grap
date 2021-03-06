%{
 
/*
 * Parser.y file
 * To generate the parser run: "bison Parser.y"
 */
 
#include "Expression.hpp"
#include "Parser.hpp"
#include "Lexer.hpp"

#define YYINITDEPTH 200000
#define YYMAXDEPTH 1000000

int yyerror(GraphList **SgraphList, yyscan_t scanner, const char *msg) {
    // Add error handling routine as needed
    std::cerr << "WARNING: An error occurred while parsing a DOT file." << std::endl;
    return 0;
}
 
%}

%code requires {
#ifndef YY_TYPEDEF_YY_SCANNER_T
#define YY_TYPEDEF_YY_SCANNER_T
typedef void* yyscan_t;
#endif
}
%error-verbose

%define api.pure

%lex-param   { yyscan_t scanner }
%parse-param { GraphList** SgraphList }
%parse-param { yyscan_t scanner }

%union {
    char* type_string;
    int value;
    GraphList* SgraphList;
    graph_t* Sgraph;
    node_t* Snode;
    Option* Soption;
    OptionList* SoptionList;
    Couple* Sedge;
    CoupleList* SedgeList;
}
 
 
%token TOKEN_DIGRAPH_HEADER
%token <type_string> TOKEN_ID
%token <type_string> TOKEN_IDV
%token <type_string> OPTION_ID
%token <type_string> TOKEN_OPTION_STR
%type <type_string> option_value
%token TOKEN_LENS
%token TOKEN_RENS
%token TOKEN_LCRO
%token TOKEN_RCRO
%token TOKEN_EQ
%token TOKEN_VIRG
%token TOKEN_ARROW
%token <value> TOKEN_NUMBER

%type <SgraphList> graph_list
%type <Sgraph> graph
%type <Sgraph> node_list
%type <Snode> node
%type <Snode> node_id
%type <Sedge> edge
%type <SedgeList> edge_list
%type <Soption> option
%type <SoptionList> option_list

%%

input
    : graph_list { *SgraphList = $1;}
    ;
    
graph_list
    :
    {$<SgraphList>$ = createGraphList();}
    | graph_list[GL] graph[G] { $$ = addGraphToInput($G, $GL); }
    | graph_list[GL] error { $$ = $GL; }
    ;
 
graph
    : 
    TOKEN_DIGRAPH_HEADER TOKEN_LENS node_list[G] edge_list[E] TOKEN_RENS { $$ = addEdgesToGraph(NULL , $E, $G); }
    | TOKEN_DIGRAPH_HEADER TOKEN_ID[id] TOKEN_LENS node_list[G] edge_list[E] TOKEN_RENS {$$ = addEdgesToGraph($id , $E, $G); }
    ;

node_list
    :
    {$<Sgraph>$ = createGraph();}
    | node_list[G] node[nG] { $$ = addNodeToGraph($nG, $G); }
    | node_list[G] error { fprintf(stderr, "WARNING: Error parsing a node_list.\n"); $$ = $G; }
    ;
   
node
    :
    node_id[N] TOKEN_LCRO option_list[O] TOKEN_RCRO { $$ = updateNode($O, $N); }
    ;
        
node_id
    :
    TOKEN_ID { $$ = createNode($1); }
    | error { fprintf(stderr, "WARNING: Error parsing a node_id.\n"); $$ = NULL; }
    ;
    
option_list
    :
    {$<SoptionList>$ = createOptionList();}
    | option[O] option_list[L] { $$ = addOptionToList($O, $L); }
    | option[O] TOKEN_VIRG option_list[L] { $$ = addOptionToList($O, $L); }
    | error option_list[L] { $$ = $L; }
    ;
    
option_value
    :
    TOKEN_ID[V] { $$ = $V; }
    | TOKEN_IDV[V] { $$ = $V; }
    | error { fprintf(stderr, "WARNING: Error parsing an option_value.\n"); $$ = NULL; }
    ;
    
option
    :
    TOKEN_ID[I] TOKEN_EQ option_value[V] { $$ = createOption($I, $V); }
    | error { fprintf(stderr, "WARNING: Error parsing an option.\n"); $$ = NULL; }
    ;
    
edge_list
    :
    {$<SedgeList>$ = createEdgeList();}
    | edge[E] edge_list[L] { $$ = addEdgeToList($E, $L); }
    | error edge_list[L] { fprintf(stderr, "WARNING: Error parsing an edge_list.\n"); $$ = $L; }
    ;
    
edge
    :
    TOKEN_ID[F] TOKEN_ARROW TOKEN_ID[C] TOKEN_LCRO option_list[L] TOKEN_RCRO { $$ = createEdge($F, $C, $L); }
    | TOKEN_ID[F] TOKEN_ARROW TOKEN_ID[C] { $$ = createEdge($F, $C, NULL); }
    ;
 
%%
