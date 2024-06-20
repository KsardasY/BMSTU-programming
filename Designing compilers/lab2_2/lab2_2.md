Program -> ((Struct|Union|Enum)";")*

Struct -> "struct"Body

Body -> (Ident IdentList)|(Ident?("{"((Struct|Union|Enum|Declaration)";")*"}"IdentList?)?)

Ident -> [a-zA-Z][a-zA-Z0-9]\*

IdentList -> "\*"\*Ident(",""*"*Ident)\*

Declaration -> Type IdentList

Type -> ("int"|"long"|"double"|"float"|"char"|"short"|"signed"|"unsigned")"*"\*

Union -> "union"Body

Number -> [0-9]+

Sizeof -> "sizeof("(Type|Struct|Enum|Union)")"

Sign -> "+"|"-"|"/"|"*"

Expression -> Number|Sizeof|Ident(Sign(Number|Sizeof|Ident))*

EnumIdent -> Ident("["Expression"]")*

EnumIdentList -> "\*"\*EnumIdent(",""*"*EnumIdent)\*

Enum -> "enum"Ident?"{"EnumBody"}"EnumIdentList

Assignment -> Ident"="Expression

EnumBody -> ((Ident|Assignment)",")*(Ident|Assignment)?
