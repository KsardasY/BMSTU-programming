%option noyywrap bison-bridge bison-locations
%{
#include <stdio.h>
#include <stdlib.h>

#define TAG_COMMENT 1
#define TAG_KEYWORD 2
#define TAG_IDENT 3
#define TAG_NUMBER 4

char *tag_names[] = {"END_OF_PROGRAM", "COMMENT", "KEYWORD", "IDENT", "NUMBER"};

typedef struct Position Position;

struct Position {
    int line, pos, index;
};

void print_pos(Position *p) {
    printf("(%d,%d)",p->line,p->pos);
}

struct Fragment {
    Position starting, following;
};

typedef struct Fragment YYLTYPE;
typedef struct Fragment Fragment;

void print_frag(Fragment* f) {
    print_pos(&(f->starting));
    printf("-");
    print_pos(&(f->following));
}

union Token {
    long number;
    int ident;
    char *value;
};

typedef union Token YYSTYPE;

int continued;
struct Position cur;
#define YY_USER_ACTION {             \
    int i;                           \
    if (!continued)                  \
        yylloc->starting = cur;      \
    continued = 0;                   \
    for ( i = 0; i < yyleng; i++){   \
        if ( yytext[i] == '\n'){     \
            cur.line++;              \
            cur.pos = 1;             \
        }                            \
        else                         \
            cur.pos++;               \
        cur.index++;                 \
    }                                \
    yylloc->following = cur;         \
}

long size_comment;

void init_scanner (char *program){
    continued = 0;
    cur.line = 1;
    cur.pos = 1;
    cur.index = 0;
    yy_scan_string(program);
}

void err (char *msg){
    printf ("Error");
    print_pos(&cur);
    printf(":%s\n",msg);
}

typedef struct{
    int size;
    char** names;
} identTable;

void create_ident_table(identTable *t){
    t->size = 0;
    t->names = NULL;
}

int add_ident(identTable* table, char* name){
    for (int i = 0; i < table->size; i++){
        if (strcmp(name, table->names[i]) == 0){
            return i;
        }
    }

    table->size++;
    if (table->size == 1){
        table->names = (char**)malloc(sizeof(char*) * (table->size));
    }
    else {
        table->names = (char**)realloc(table->names, sizeof(char*) * (table->size));
    }
    table->names[table->size - 1] = (char*)malloc(sizeof(char)*strlen(name));
    strcpy(table->names[table->size - 1], name);
    return table->size-1;
}

identTable table;

typedef struct {
    int size;
    Fragment *comments;
} commentTable;

void add_comment(commentTable* table, Fragment* comment){
    table->size++;
    if (table->size == 1){
        table->comments = (Fragment*)malloc(sizeof(Fragment) * (table->size));
    }
    else {
        table->comments = (Fragment*)realloc(table->comments, sizeof(Fragment) * (table->size));
    }
    table->comments[table->size - 1] = *comment;
}

commentTable comment_table;

%}

COMMENT \/\/[^\n]*
KEYWORD \/while\/|\/do\/|\/end\/
IDENT \/[^\n/]*\/
NUMBER [0-9]+


%x STRING

%%
[\n\t\r ]+


{COMMENT}           {
    add_comment(&comment_table, yylloc);
    yylval->value = yytext;
    return TAG_COMMENT;
}

{KEYWORD}   {
    yylval->value = yytext;
    return TAG_KEYWORD;
}

{IDENT}               {
    yylval->ident = add_ident(&table, yytext);
    return TAG_IDENT;
}

{NUMBER}    {
    yylval->number = atol(yytext);
    return TAG_NUMBER;
}


.                     err ("ERROR");

<<EOF>>               return 0;


%%


int main(){
    int tag;
    YYSTYPE value;
    YYLTYPE coords;
    FILE *inputfile;
    long size_str;
    char *str;
    union Token token;
    inputfile = fopen("test.txt","r");
    if (inputfile == NULL) {
        fputs("File not found", stderr);
        exit(1);
    }
    fseek(inputfile, 0,SEEK_END);
    size_str = ftell(inputfile);
    rewind(inputfile);
    str=(char*)malloc(sizeof(char)*(size_str+1));
    if (str == NULL) {
        fputs("Memory error",stderr);
        exit(2);
    }
    size_t n = fread(str,sizeof(char),size_str,inputfile);
    if (n != size_str) {
        fputs ("Reading error",stderr);
        exit (3);
    }
    str[size_str] = '\0';
    fclose(inputfile);
    init_scanner(str);
    do{
        tag = yylex(&value, &coords);
        if (tag == TAG_IDENT) {
            printf("%s ",tag_names[tag]);
            print_frag(&coords);
            printf(":\n%d\n", value.ident);
        }
        else if (tag == TAG_NUMBER){
            printf("%s ",tag_names[tag]);
            print_frag(&coords);
            printf(":\n%ld\n", value.number);
        }
        else if (tag == TAG_KEYWORD) {
            printf("%s ",tag_names[tag]);
            print_frag(&coords);
            printf(":\n%s\n", value.value);
        }
        else {
            printf("%s ",tag_names[tag]);
            print_frag(&coords);
            printf(":\n");
        }
    }
    while (tag != 0);
    printf("COMMENTS\n");
    for (int i = 0; i < comment_table.size; i++){
        print_frag(&comment_table.comments[i]);
        printf("\n");
    }
    free(str);
    free(table.names);
    free(comment_table.comments);
    return 0;
}
