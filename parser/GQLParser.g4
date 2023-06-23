parser grammar GQLParser;

options { tokenVocab = GQLLexer; }

gqlRequest
   : gqlProgram SEMICOLON? EOF
   ;

gqlProgram
   : programActivity sessionCloseCommand?
   | sessionCloseCommand
   ;

programActivity
   : sessionActivity
   | transactionActivity
   ;

sessionActivity
   : sessionActivityCommand+
   ;

sessionActivityCommand
   : sessionSetCommand
   | sessionResetCommand
   ;

transactionActivity
   : startTransactionCommand (procedureSpecification endTransactionCommand?)?
   | procedureSpecification endTransactionCommand?
   | endTransactionCommand
   ;

endTransactionCommand
   : rollbackCommand
   | commitCommand
   ;

sessionSetCommand
   : 'SESSION' 'SET' (sessionSetSchemaClause | sessionSetGraphClause | sessionSetTimeZoneClause | sessionSetParameterClause)
   ;

sessionSetSchemaClause
   : 'SCHEMA' schemaReference
   ;

sessionSetGraphClause
   : 'PROPERTY'? 'GRAPH' graphExpression
   ;

sessionSetTimeZoneClause
   : 'TIME' 'ZONE' setTimeZoneValue
   ;

setTimeZoneValue
   : stringValueExpression
   ;

sessionSetParameterClause
   : sessionSetGraphParameterClause
   | sessionSetBindingTableParameterClause
   | sessionSetValueParameterClause
   ;

sessionSetGraphParameterClause
   : 'PROPERTY'? 'GRAPH' sessionSetParameterName optTypedGraphInitializer
   ;

sessionSetBindingTableParameterClause
   : 'BINDING'? 'TABLE' sessionSetParameterName optTypedBindingTableInitializer
   ;

sessionSetValueParameterClause
   : 'VALUE' sessionSetParameterName optTypedValueInitializer
   ;

sessionSetParameterName
   : ('IF' 'NOT' 'EXISTS')? PARAMETER_NAME
   ;

sessionResetCommand
   : 'SESSION' 'RESET' sessionResetArguments?
   ;

sessionResetArguments
   : 'ALL'? ('PARAMETERS' | 'CHARACTERISTICS')
   | 'SCHEMA'
   | 'PROPERTY'? 'GRAPH'
   | 'TIME' 'ZONE'
   | 'PARAMETER'? PARAMETER_NAME
   ;

sessionCloseCommand
   : 'SESSION' 'CLOSE'
   ;

startTransactionCommand
   : 'START' 'TRANSACTION' transactionCharacteristics?
   ;

transactionCharacteristics
   : transactionMode (COMMA transactionMode)*
   ;

transactionMode
   : transactionAccessMode
   | implementationDefinedAccessMode
   ;

transactionAccessMode
   : 'READ' 'ONLY'
   | 'READ' 'WRITE'
   ;

implementationDefinedAccessMode
   : seeTheRules
   ;

rollbackCommand
   : 'ROLLBACK'
   ;

commitCommand
   : 'COMMIT'
   ;

nestedProcedureSpecification
   : LEFT_BRACE procedureSpecification RIGHT_BRACE
   ;

procedureSpecification
   : catalogModifyingProcedureSpecification
   | dataModifyingProcedureSpecification
   | querySpecification
   ;

catalogModifyingProcedureSpecification
   : procedureBody
   ;

nestedDataModifyingProcedureSpecification
   : LEFT_BRACE dataModifyingProcedureSpecification RIGHT_BRACE
   ;

dataModifyingProcedureSpecification
   : procedureBody
   ;

nestedQuerySpecification
   : LEFT_BRACE querySpecification RIGHT_BRACE
   ;

querySpecification
   : procedureBody
   ;

procedureBody
   : atSchemaClause? bindingVariableDefinitionBlock? statementBlock
   ;

bindingVariableDefinitionBlock
   : bindingVariableDefinition+
   ;

bindingVariableDefinition
   : graphVariableDefinition
   | bindingTableVariableDefinition
   | valueVariableDefinition
   ;

statementBlock
   : statement nextStatement*
   ;

statement
   : linearCatalogModifyingStatement
   | linearDataModifyingStatement
   | compositeQueryStatement
   ;

nextStatement
   : 'NEXT' yieldClause? statement
   ;

graphVariableDefinition
   : 'PROPERTY'? 'GRAPH' GRAPH_VARIABLE optTypedGraphInitializer
   ;

optTypedGraphInitializer
   : (typed? graphReferenceValueType)? graphInitializer
   ;

graphInitializer
   : EQUALS_OPERATOR graphExpression
   ;

bindingTableVariableDefinition
   : 'BINDING'? 'TABLE' BINDING_TABLE_VARIABLE optTypedBindingTableInitializer
   ;

optTypedBindingTableInitializer
   : (typed? bindingTableReferenceValueType)? bindingTableInitializer
   ;

bindingTableInitializer
   : EQUALS_OPERATOR bindingTableExpression
   ;

valueVariableDefinition
   : 'VALUE' VALUE_VARIABLE optTypedValueInitializer
   ;

optTypedValueInitializer
   : (typed? valueType)? valueInitializer
   ;

valueInitializer
   : EQUALS_OPERATOR valueExpression
   ;

graphExpression
   : nestedGraphQuerySpecification
   | objectExpressionPrimary
   | graphReference
   | OBJECT_NAME_OR_BINDING_VARIABLE
   | currentGraph
   ;

currentGraph
   : 'CURRENT_PROPERTY_GRAPH'
   | 'CURRENT_GRAPH'
   ;

nestedGraphQuerySpecification
   : nestedQuerySpecification
   ;

bindingTableExpression
   : nestedBindingTableQuerySpecification
   | objectExpressionPrimary
   | bindingTableReference
   | OBJECT_NAME_OR_BINDING_VARIABLE
   ;

nestedBindingTableQuerySpecification
   : nestedQuerySpecification
   ;

objectExpressionPrimary
   : 'VARIABLE' valueExpressionPrimary
   | parenthesizedValueExpression
   | nonParenthesizedValueExpressionPrimarySpecialCase
   ;

linearCatalogModifyingStatement
   : simpleCatalogModifyingStatement+
   ;

simpleCatalogModifyingStatement
   : primitiveCatalogModifyingStatement
   | callCatalogModifyingProcedureStatement
   ;

primitiveCatalogModifyingStatement
   : createSchemaStatement
   | dropSchemaStatement
   | createGraphStatement
   | dropGraphStatement
   | createGraphTypeStatement
   | dropGraphTypeStatement
   ;

createSchemaStatement
   : 'CREATE' 'SCHEMA' ('IF' 'NOT' 'EXISTS')? catalogSchemaParentAndName
   ;

dropSchemaStatement
   : 'DROP' 'SCHEMA' ('IF' 'EXISTS')? catalogSchemaParentAndName
   ;

createGraphStatement
   : 'CREATE' ('PROPERTY'? 'GRAPH' ('IF' 'NOT' 'EXISTS')? | 'OR' 'REPLACE' 'PROPERTY'? 'GRAPH') catalogGraphParentAndName (openGraphType | ofGraphType) graphSource?
   ;

openGraphType
   : typed? 'ANY' ('PROPERTY'? 'GRAPH')?
   ;

ofGraphType
   : graphTypeLikeGraph
   | typed? graphTypeReference
   | typed? ('PROPERTY'? 'GRAPH')? nestedGraphTypeSpecification
   ;

graphTypeLikeGraph
   : 'LIKE' graphExpression
   ;

graphSource
   : 'AS' 'COPY' 'OF' graphExpression
   ;

dropGraphStatement
   : 'DROP' 'PROPERTY'? 'GRAPH' ('IF' 'EXISTS')? catalogGraphParentAndName
   ;

createGraphTypeStatement
   : 'CREATE' ('PROPERTY'? 'GRAPH' 'TYPE' ('IF' 'NOT' 'EXISTS')? | 'OR' 'REPLACE' 'PROPERTY'? 'GRAPH' 'TYPE') catalogGraphTypeParentAndName graphTypeSource
   ;

graphTypeSource
   : 'AS'? copyOfGraphType
   | graphTypeLikeGraph
   | 'AS'? nestedGraphTypeSpecification
   ;

copyOfGraphType
   : 'COPY' 'OF' (graphTypeReference | externalObjectReference)
   ;

dropGraphTypeStatement
   : 'DROP' 'PROPERTY'? 'GRAPH' 'TYPE' ('IF' 'EXISTS')? catalogGraphTypeParentAndName
   ;

callCatalogModifyingProcedureStatement
   : callProcedureStatement
   ;

linearDataModifyingStatement
   : focusedLinearDataModifyingStatement
   | ambientLinearDataModifyingStatement
   ;

focusedLinearDataModifyingStatement
   : focusedLinearDataModifyingStatementBody
   | focusedNestedDataModifyingProcedureSpecification
   ;

focusedLinearDataModifyingStatementBody
   : useGraphClause simpleLinearDataAccessingStatement primitiveResultStatement?
   ;

focusedNestedDataModifyingProcedureSpecification
   : useGraphClause nestedDataModifyingProcedureSpecification
   ;

ambientLinearDataModifyingStatement
   : ambientLinearDataModifyingStatementBody
   | nestedDataModifyingProcedureSpecification
   ;

ambientLinearDataModifyingStatementBody
   : simpleLinearDataAccessingStatement primitiveResultStatement?
   ;

simpleLinearDataAccessingStatement
   : simpleDataAccessingStatement+
   ;

simpleDataAccessingStatement
   : simpleQueryStatement
   | simpleDataModifyingStatement
   ;

simpleDataModifyingStatement
   : primitiveDataModifyingStatement
   | callDataModifyingProcedureStatement
   ;

primitiveDataModifyingStatement
   : insertStatement
   | setStatement
   | removeStatement
   | deleteStatement
   ;

insertStatement
   : 'INSERT' insertGraphPattern
   ;

setStatement
   : 'SET' setItemList
   ;

setItemList
   : setItem (COMMA setItem)*
   ;

setItem
   : setPropertyItem
   | setAllPropertiesItem
   | setLabelItem
   ;

setPropertyItem
   : bindingVariableReference PERIOD PROPERTY_NAME EQUALS_OPERATOR valueExpression
   ;

setAllPropertiesItem
   : bindingVariableReference EQUALS_OPERATOR LEFT_BRACE propertyKeyValuePairList? RIGHT_BRACE
   ;

setLabelItem
   : bindingVariableReference isOrColon LABEL_NAME
   ;

removeStatement
   : 'REMOVE' removeItemList
   ;

removeItemList
   : removeItem (COMMA removeItem)*
   ;

removeItem
   : removePropertyItem
   | removeLabelItem
   ;

removePropertyItem
   : bindingVariableReference PERIOD PROPERTY_NAME
   ;

removeLabelItem
   : bindingVariableReference isOrColon LABEL_NAME
   ;

deleteStatement
   : ('DETACH' | 'NODETACH')? 'DELETE' deleteItemList
   ;

deleteItemList
   : deleteItem (COMMA deleteItem)*
   ;

deleteItem
   : valueExpression
   ;

callDataModifyingProcedureStatement
   : callProcedureStatement
   ;

compositeQueryStatement
   : compositeQueryExpression
   ;

compositeQueryExpression
   : compositeQueryExpression queryConjunction compositeQueryPrimary
   | compositeQueryPrimary
   ;

queryConjunction
   : setOperator
   | 'OTHERWISE'
   ;

setOperator
   : 'UNION' setQuantifier?
   | 'EXCEPT' setQuantifier?
   | 'INTERSECT' setQuantifier?
   ;

compositeQueryPrimary
   : linearQueryStatement
   ;

linearQueryStatement
   : focusedLinearQueryStatement
   | ambientLinearQueryStatement
   ;

focusedLinearQueryStatement
   : focusedLinearQueryStatementPart* focusedLinearQueryAndPrimitiveResultStatementPart
   | focusedPrimitiveResultStatement
   | focusedNestedQuerySpecification
   | selectStatement
   ;

focusedLinearQueryStatementPart
   : useGraphClause simpleLinearQueryStatement
   ;

focusedLinearQueryAndPrimitiveResultStatementPart
   : useGraphClause simpleLinearQueryStatement primitiveResultStatement
   ;

focusedPrimitiveResultStatement
   : useGraphClause primitiveResultStatement
   ;

focusedNestedQuerySpecification
   : useGraphClause nestedQuerySpecification
   ;

ambientLinearQueryStatement
   : simpleLinearQueryStatement? primitiveResultStatement
   | nestedQuerySpecification
   ;

simpleLinearQueryStatement
   : simpleQueryStatement+
   ;

simpleQueryStatement
   : primitiveQueryStatement
   | callQueryStatement
   ;

primitiveQueryStatement
   : matchStatement
   | letStatement
   | forStatement
   | filterStatement
   | orderByAndPageStatement
   ;

matchStatement
   : simpleMatchStatement
   | optionalMatchStatement
   ;

simpleMatchStatement
   : 'MATCH' graphPatternBindingTable
   ;

optionalMatchStatement
   : 'OPTIONAL' optionalOperand
   ;

optionalOperand
   : simpleMatchStatement
   | LEFT_BRACE matchStatementBlock RIGHT_BRACE
   | LEFT_PAREN matchStatementBlock RIGHT_PAREN
   ;

matchStatementBlock
   : matchStatement+
   ;

callQueryStatement
   : callProcedureStatement
   ;

filterStatement
   : 'FILTER' (whereClause | searchCondition)
   ;

letStatement
   : 'LET' letVariableDefinitionList
   ;

letVariableDefinitionList
   : letVariableDefinition (COMMA letVariableDefinition)*
   ;

letVariableDefinition
   : valueVariableDefinition
   | VALUE_VARIABLE EQUALS_OPERATOR valueExpression
   ;

forStatement
   : 'FOR' forItem forOrdinalityOrOffset?
   ;

forItem
   : forItemAlias listValueExpression
   ;

forItemAlias
   : IDENTIFIER 'IN'
   ;

forOrdinalityOrOffset
   : 'WITH' ('ORDINALITY' | 'OFFSET') IDENTIFIER
   ;

orderByAndPageStatement
   : orderByClause offsetClause? limitClause?
   | offsetClause limitClause?
   | limitClause
   ;

primitiveResultStatement
   : returnStatement orderByAndPageStatement?
   | 'FINISH'
   ;

returnStatement
   : 'RETURN' returnStatementBody
   ;

returnStatementBody
   : setQuantifier? (ASTERISK | returnItemList) groupByClause?
   | 'NO' 'BINDINGS'
   ;

returnItemList
   : returnItem (COMMA returnItem)*
   ;

returnItem
   : aggregatingValueExpression returnItemAlias?
   ;

returnItemAlias
   : 'AS' IDENTIFIER
   ;

selectStatement
   : 'SELECT' setQuantifier? (ASTERISK | selectItemList) (selectStatementBody whereClause? groupByClause? havingClause? orderByClause? offsetClause? limitClause?)?
   ;

selectItemList
   : selectItem (COMMA selectItem)*
   ;

selectItem
   : aggregatingValueExpression selectItemAlias?
   ;

selectItemAlias
   : 'AS' IDENTIFIER
   ;

havingClause
   : 'HAVING' searchCondition
   ;

selectStatementBody
   : 'FROM' (selectGraphMatchList | selectQuerySpecification)
   ;

selectGraphMatchList
   : selectGraphMatch (COMMA selectGraphMatch)*
   ;

selectGraphMatch
   : graphExpression matchStatement
   ;

selectQuerySpecification
   : nestedQuerySpecification
   | graphExpression nestedQuerySpecification
   ;

callProcedureStatement
   : 'OPTIONAL'? 'CALL' procedureCall
   ;

procedureCall
   : inlineProcedureCall
   | namedProcedureCall
   ;

inlineProcedureCall
   : variableScopeClause? nestedProcedureSpecification
   ;

variableScopeClause
   : LEFT_PAREN bindingVariableReferenceList? RIGHT_PAREN
   ;

bindingVariableReferenceList
   : bindingVariableReference (COMMA bindingVariableReference)*
   ;

namedProcedureCall
   : procedureReference LEFT_PAREN procedureArgumentList? RIGHT_PAREN yieldClause?
   ;

procedureArgumentList
   : procedureArgument (COMMA procedureArgument)*
   ;

procedureArgument
   : valueExpression
   ;

useGraphClause
   : 'USE' graphExpression
   ;

atSchemaClause
   : 'AT' schemaReference
   ;

bindingVariableReference
   : BINDING_VARIABLE
   ;

elementVariableReference
   : bindingVariableReference
   ;

pathVariableReference
   : bindingVariableReference
   ;

parameter
   : PARAMETER_NAME
   ;

graphPatternBindingTable
   : graphPattern graphPatternYieldClause?
   ;

graphPatternYieldClause
   : 'YIELD' graphPatternYieldItemList
   ;

graphPatternYieldItemList
   : graphPatternYieldItem (COMMA graphPatternYieldItem)*
   | 'NO' 'BINDINGS'
   ;

graphPatternYieldItem
   : elementVariableReference
   | pathVariableReference
   ;

graphPattern
   : matchMode? pathPatternList keepClause? graphPatternWhereClause?
   ;

matchMode
   : repeatableElementsMatchMode
   | differentEdgesMatchMode
   ;

repeatableElementsMatchMode
   : 'REPEATABLE' elementBindingsOrElements
   ;

differentEdgesMatchMode
   : 'DIFFERENT' edgeBindingsOrEdges
   ;

elementBindingsOrElements
   : 'ELEMENT' 'BINDINGS'?
   | 'ELEMENTS'
   ;

edgeBindingsOrEdges
   : EDGE_SYNONYM 'BINDINGS'?
   | EDGES_SYNONYM
   ;

pathPatternList
   : pathPattern (COMMA pathPattern)*
   ;

pathPattern
   : pathVariableDeclaration? pathPatternPrefix? pathPatternExpression
   ;

pathVariableDeclaration
   : PATH_VARIABLE EQUALS_OPERATOR
   ;

keepClause
   : 'KEEP' pathPatternPrefix
   ;

graphPatternWhereClause
   : 'WHERE' searchCondition
   ;

pathPatternPrefix
   : pathModePrefix
   | pathSearchPrefix
   ;

pathModePrefix
   : pathMode pathOrPaths?
   ;

pathMode
   : 'WALK'
   | 'TRAIL'
   | 'SIMPLE'
   | 'ACYCLIC'
   ;

pathSearchPrefix
   : allPathSearch
   | anyPathSearch
   | shortestPathSearch
   ;

allPathSearch
   : 'ALL' pathMode? pathOrPaths?
   ;

pathOrPaths
   : 'PATH'
   | 'PATHS'
   ;

anyPathSearch
   : 'ANY' numberOfPaths? pathMode? pathOrPaths?
   ;

numberOfPaths
   : unsignedIntegerSpecification
   ;

shortestPathSearch
   : allShortestPathSearch
   | anyShortestPathSearch
   | countedShortestPathSearch
   | countedShortestGroupSearch
   ;

allShortestPathSearch
   : 'ALL' 'SHORTEST' pathMode? pathOrPaths?
   ;

anyShortestPathSearch
   : 'ANY' 'SHORTEST' pathMode? pathOrPaths?
   ;

countedShortestPathSearch
   : 'SHORTEST' numberOfPaths pathMode? pathOrPaths?
   ;

countedShortestGroupSearch
   : 'SHORTEST' numberOfGroups? pathMode? pathOrPaths? ('GROUP' | 'GROUPS')
   ;

numberOfGroups
   : unsignedIntegerSpecification
   ;

pathPatternExpression
   : pathTerm
   | pathMultisetAlternation
   | pathPatternUnion
   ;

pathMultisetAlternation
   : pathTerm MULTISET_ALTERNATION_OPERATOR pathTerm (MULTISET_ALTERNATION_OPERATOR pathTerm)*
   ;

pathPatternUnion
   : pathTerm VERTICAL_BAR pathTerm (VERTICAL_BAR pathTerm)*
   ;

pathTerm
   : pathFactor
   | pathConcatenation
   ;

pathConcatenation
   : pathTerm pathFactor
   ;

pathFactor
   : pathPrimary
   | quantifiedPathPrimary
   | questionedPathPrimary
   ;

quantifiedPathPrimary
   : pathPrimary graphPatternQuantifier
   ;

questionedPathPrimary
   : pathPrimary QUESTION_MARK
   ;

pathPrimary
   : elementPattern
   | parenthesizedPathPatternExpression
   | simplifiedPathPatternExpression
   ;

elementPattern
   : nodePattern
   | edgePattern
   ;

nodePattern
   : LEFT_PAREN elementPatternFiller RIGHT_PAREN
   ;

elementPatternFiller
   : elementVariableDeclaration? isLabelExpression? elementPatternPredicate?
   ;

elementVariableDeclaration
   : 'TEMP'? ELEMENT_VARIABLE
   ;

isLabelExpression
   : isOrColon labelExpression
   ;

isOrColon
   : 'IS'
   | COLON
   ;

elementPatternPredicate
   : elementPatternWhereClause
   | elementPropertySpecification
   ;

elementPatternWhereClause
   : 'WHERE' searchCondition
   ;

elementPropertySpecification
   : LEFT_BRACE propertyKeyValuePairList RIGHT_BRACE
   ;

propertyKeyValuePairList
   : propertyKeyValuePair (COMMA propertyKeyValuePair)*
   ;

propertyKeyValuePair
   : PROPERTY_NAME COLON valueExpression
   ;

edgePattern
   : fullEdgePattern
   | abbreviatedEdgePattern
   ;

fullEdgePattern
   : fullEdgePointingLeft
   | fullEdgeUndirected
   | fullEdgePointingRight
   | fullEdgeLeftOrUndirected
   | fullEdgeUndirectedOrRight
   | fullEdgeLeftOrRight
   | fullEdgeAnyDirection
   ;

fullEdgePointingLeft
   : LEFT_ARROW_BRACKET elementPatternFiller RIGHT_BRACKET_MINUS
   ;

fullEdgeUndirected
   : TILDE_LEFT_BRACKET elementPatternFiller RIGHT_BRACKET_TILDE
   ;

fullEdgePointingRight
   : MINUS_LEFT_BRACKET elementPatternFiller BRACKET_RIGHT_ARROW
   ;

fullEdgeLeftOrUndirected
   : LEFT_ARROW_TILDE_BRACKET elementPatternFiller RIGHT_BRACKET_TILDE
   ;

fullEdgeUndirectedOrRight
   : TILDE_LEFT_BRACKET elementPatternFiller BRACKET_TILDE_RIGHT_ARROW
   ;

fullEdgeLeftOrRight
   : LEFT_ARROW_BRACKET elementPatternFiller BRACKET_RIGHT_ARROW
   ;

fullEdgeAnyDirection
   : MINUS_LEFT_BRACKET elementPatternFiller RIGHT_BRACKET_MINUS
   ;

abbreviatedEdgePattern
   : LEFT_ARROW
   | TILDE
   | RIGHT_ARROW
   | LEFT_ARROW_TILDE
   | TILDE_RIGHT_ARROW
   | LEFT_MINUS_RIGHT
   | MINUS_SIGN
   ;

parenthesizedPathPatternExpression
   : LEFT_PAREN subpathVariableDeclaration? pathModePrefix? pathPatternExpression parenthesizedPathPatternWhereClause? RIGHT_PAREN
   ;

subpathVariableDeclaration
   : SUBPATH_VARIABLE EQUALS_OPERATOR
   ;

parenthesizedPathPatternWhereClause
   : 'WHERE' searchCondition
   ;

insertGraphPattern
   : insertPathPatternList
   ;

insertPathPatternList
   : insertPathPattern (COMMA insertPathPattern)*
   ;

insertPathPattern
   : insertNodePattern (insertEdgePattern insertNodePattern)*
   ;

insertNodePattern
   : LEFT_PAREN insertElementPatternFiller? RIGHT_PAREN
   ;

insertEdgePattern
   : insertEdgePointingLeft
   | insertEdgePointingRight
   | insertEdgeUndirected
   ;

insertEdgePointingLeft
   : LEFT_ARROW_BRACKET insertElementPatternFiller? RIGHT_BRACKET_MINUS
   ;

insertEdgePointingRight
   : MINUS_LEFT_BRACKET insertElementPatternFiller? BRACKET_RIGHT_ARROW
   ;

insertEdgeUndirected
   : TILDE_LEFT_BRACKET insertElementPatternFiller? RIGHT_BRACKET_TILDE
   ;

insertElementPatternFiller
   : elementVariableDeclaration labelAndPropertySetSpecification?
   | elementVariableDeclaration? labelAndPropertySetSpecification
   ;

labelAndPropertySetSpecification
   : labelSetSpecification elementPropertySpecification?
   | labelSetSpecification? elementPropertySpecification
   ;

labelSetSpecification
   : LABEL_NAME (AMPERSAND LABEL_NAME)*
   ;

labelExpression
   : labelTerm
   | labelDisjunction
   ;

labelDisjunction
   : labelExpression VERTICAL_BAR labelTerm
   ;

labelTerm
   : labelFactor
   | labelConjunction
   ;

labelConjunction
   : labelTerm AMPERSAND labelFactor
   ;

labelFactor
   : labelPrimary
   | labelNegation
   ;

labelNegation
   : EXCLAMATION_MARK labelPrimary
   ;

labelPrimary
   : LABEL_NAME
   | wildcardLabel
   | parenthesizedLabelExpression
   ;

wildcardLabel
   : PERCENT
   ;

parenthesizedLabelExpression
   : LEFT_PAREN labelExpression RIGHT_PAREN
   ;

graphPatternQuantifier
   : ASTERISK
   | PLUS_SIGN
   | fixedQuantifier
   | generalQuantifier
   ;

fixedQuantifier
   : LEFT_BRACE UNSIGNED_INTEGER RIGHT_BRACE
   ;

generalQuantifier
   : LEFT_BRACE lowerBound? COMMA upperBound? RIGHT_BRACE
   ;

lowerBound
   : UNSIGNED_INTEGER
   ;

upperBound
   : UNSIGNED_INTEGER
   ;

simplifiedPathPatternExpression
   : simplifiedDefaultingLeft
   | simplifiedDefaultingUndirected
   | simplifiedDefaultingRight
   | simplifiedDefaultingLeftOrUndirected
   | simplifiedDefaultingUndirectedOrRight
   | simplifiedDefaultingLeftOrRight
   | simplifiedDefaultingAnyDirection
   ;

simplifiedDefaultingLeft
   : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS
   ;

simplifiedDefaultingUndirected
   : TILDE_SLASH simplifiedContents SLASH_TILDE
   ;

simplifiedDefaultingRight
   : MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT
   ;

simplifiedDefaultingLeftOrUndirected
   : LEFT_TILDE_SLASH simplifiedContents SLASH_TILDE
   ;

simplifiedDefaultingUndirectedOrRight
   : TILDE_SLASH simplifiedContents SLASH_TILDE_RIGHT
   ;

simplifiedDefaultingLeftOrRight
   : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT
   ;

simplifiedDefaultingAnyDirection
   : MINUS_SLASH simplifiedContents SLASH_MINUS
   ;

simplifiedContents
   : simplifiedTerm
   | simplifiedPathUnion
   | simplifiedMultisetAlternation
   ;

simplifiedPathUnion
   : simplifiedTerm VERTICAL_BAR simplifiedTerm (VERTICAL_BAR simplifiedTerm)*
   ;

simplifiedMultisetAlternation
   : simplifiedTerm MULTISET_ALTERNATION_OPERATOR simplifiedTerm (MULTISET_ALTERNATION_OPERATOR simplifiedTerm)*
   ;

simplifiedTerm
   : simplifiedFactorLow
   | simplifiedConcatenation
   ;

simplifiedConcatenation
   : simplifiedTerm simplifiedFactorLow
   ;

simplifiedFactorLow
   : simplifiedFactorHigh
   | simplifiedConjunction
   ;

simplifiedConjunction
   : simplifiedFactorLow AMPERSAND simplifiedFactorHigh
   ;

simplifiedFactorHigh
   : simplifiedTertiary
   | simplifiedQuantified
   | simplifiedQuestioned
   ;

simplifiedQuantified
   : simplifiedTertiary graphPatternQuantifier
   ;

simplifiedQuestioned
   : simplifiedTertiary QUESTION_MARK
   ;

simplifiedTertiary
   : simplifiedDirectionOverride
   | simplifiedSecondary
   ;

simplifiedDirectionOverride
   : simplifiedOverrideLeft
   | simplifiedOverrideUndirected
   | simplifiedOverrideRight
   | simplifiedOverrideLeftOrUndirected
   | simplifiedOverrideUndirectedOrRight
   | simplifiedOverrideLeftOrRight
   | simplifiedOverrideAnyDirection
   ;

simplifiedOverrideLeft
   : LEFT_ANGLE_BRACKET simplifiedSecondary
   ;

simplifiedOverrideUndirected
   : TILDE simplifiedSecondary
   ;

simplifiedOverrideRight
   : simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideLeftOrUndirected
   : LEFT_ARROW_TILDE simplifiedSecondary
   ;

simplifiedOverrideUndirectedOrRight
   : TILDE simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideLeftOrRight
   : LEFT_ANGLE_BRACKET simplifiedSecondary RIGHT_ANGLE_BRACKET
   ;

simplifiedOverrideAnyDirection
   : MINUS_SIGN simplifiedSecondary
   ;

simplifiedSecondary
   : simplifiedPrimary
   | simplifiedNegation
   ;

simplifiedNegation
   : EXCLAMATION_MARK simplifiedPrimary
   ;

simplifiedPrimary
   : LABEL_NAME
   | LEFT_PAREN simplifiedContents RIGHT_PAREN
   ;

whereClause
   : 'WHERE' searchCondition
   ;

yieldClause
   : 'YIELD' yieldItemList
   ;

yieldItemList
   : yieldItem (COMMA yieldItem)*
   ;

yieldItem
   : (yieldItemName yieldItemAlias?)
   ;

yieldItemName
   : FIELD_NAME
   ;

yieldItemAlias
   : 'AS' BINDING_VARIABLE
   ;

groupByClause
   : 'GROUP' 'BY' groupingElementList
   ;

groupingElementList
   : groupingElement  (COMMA groupingElement)?
   | emptyGroupingSet
   ;

groupingElement
   : bindingVariableReference
   ;

emptyGroupingSet
   : LEFT_PAREN RIGHT_PAREN
   ;

orderByClause
   : 'ORDER' 'BY' sortSpecificationList
   ;

aggregateFunction
   : 'COUNT' LEFT_PAREN ASTERISK RIGHT_PAREN
   | generalSetFunction
   | binarySetFunction
   ;

generalSetFunction
   : generalSetFunctionType LEFT_PAREN setQuantifier? valueExpression RIGHT_PAREN
   ;

binarySetFunction
   : binarySetFunctionType LEFT_PAREN dependentValueExpression COMMA independentValueExpression RIGHT_PAREN
   ;

generalSetFunctionType
   : 'AVG'
   | 'COUNT'
   | 'MAX'
   | 'MIN'
   | 'SUM'
   | 'COLLECT_LIST'
   | 'STDDEV_SAMP'
   | 'STDDEV_POP'
   ;

setQuantifier
   : 'DISTINCT'
   | 'ALL'
   ;

binarySetFunctionType
   : 'PERCENTILE_CONT'
   | 'PERCENTILE_DISC'
   ;

dependentValueExpression
   : setQuantifier? numericValueExpression
   ;

independentValueExpression
   : numericValueExpression
   ;

sortSpecificationList
   : sortSpecification (COMMA sortSpecification)*
   ;

sortSpecification
   : sortKey orderingSpecification? nullOrdering?
   ;

sortKey
   : aggregatingValueExpression
   ;

orderingSpecification
   : 'ASC'
   | 'ASCENDING'
   | 'DESC'
   | 'DESCENDING'
   ;

nullOrdering
   : 'NULLS' 'FIRST'
   | 'NULLS' 'LAST'
   ;

limitClause
   : 'LIMIT' unsignedIntegerSpecification
   ;

offsetClause
   : offsetSynonym unsignedIntegerSpecification
   ;

offsetSynonym
   : 'OFFSET'
   | 'SKIP'
   ;

nestedGraphTypeSpecification
   : LEFT_BRACE graphTypeSpecificationBody RIGHT_BRACE
   ;

graphTypeSpecificationBody
   : elementTypeDefinitionList
   ;

elementTypeDefinitionList
   : elementTypeDefinition (COMMA elementTypeDefinition)*
   ;

elementTypeDefinition
   : nodeTypeDefinition
   | edgeTypeDefinition
   ;

nodeTypeDefinition
   : nodeTypePattern
   | NODE_SYNONYM nodeTypePhrase
   ;

nodeTypePattern
   : LEFT_PAREN nodeTypeName? nodeTypeFiller? RIGHT_PAREN
   ;

nodeTypePhrase
   : 'TYPE'? nodeTypeName nodeTypeFiller?
   | nodeTypeFiller
   ;

nodeTypeName
   : ELEMENT_TYPE_NAME
   ;

nodeTypeFiller
   : nodeTypeLabelSetDefinition
   | nodeTypePropertyTypeSetDefinition
   | nodeTypeLabelSetDefinition nodeTypePropertyTypeSetDefinition
   ;

nodeTypeLabelSetDefinition
   : labelSetDefinition
   ;

nodeTypePropertyTypeSetDefinition
   : propertyTypeSetDefinition
   ;

edgeTypeDefinition
   : edgeTypePattern
   | edgeKind? EDGE_SYNONYM edgeTypePhrase
   ;

edgeTypePattern
   : fullEdgeTypePattern
   | abbreviatedEdgeTypePattern
   ;

edgeTypePhrase
   : 'TYPE'? edgeTypeName (edgeTypeFiller endpointDefinition)?
   | edgeTypeFiller endpointDefinition
   ;

edgeTypeName
   : ELEMENT_TYPE_NAME
   ;

edgeTypeFiller
   : edgeTypeLabelSetDefinition
   | edgeTypePropertyTypeSetDefinition
   | edgeTypeLabelSetDefinition edgeTypePropertyTypeSetDefinition
   ;

edgeTypeLabelSetDefinition
   : labelSetDefinition
   ;

edgeTypePropertyTypeSetDefinition
   : propertyTypeSetDefinition
   ;

fullEdgeTypePattern
   : fullEdgeTypePatternPointingRight
   | fullEdgeTypePatternPointingLeft
   | fullEdgeTypePatternUndirected
   ;

fullEdgeTypePatternPointingRight
   : sourceNodeTypeReference arcTypePointingRight destinationNodeTypeReference
   ;

fullEdgeTypePatternPointingLeft
   : destinationNodeTypeReference arcTypePointingLeft sourceNodeTypeReference
   ;

fullEdgeTypePatternUndirected
   : sourceNodeTypeReference arcTypeUndirected destinationNodeTypeReference
   ;

arcTypePointingRight
   : MINUS_LEFT_BRACKET arcTypeFiller BRACKET_RIGHT_ARROW
   ;

arcTypePointingLeft
   : LEFT_ARROW_BRACKET arcTypeFiller RIGHT_BRACKET_MINUS
   ;

arcTypeUndirected
   : TILDE_LEFT_BRACKET arcTypeFiller RIGHT_BRACKET_TILDE
   ;

arcTypeFiller
   : edgeTypeName? edgeTypeFiller?
   ;

abbreviatedEdgeTypePattern
   : abbreviatedEdgeTypePatternPointingRight
   | abbreviatedEdgeTypePatternPointingLeft
   | abbreviatedEdgeTypePatternUndirected
   ;

abbreviatedEdgeTypePatternPointingRight
   : sourceNodeTypeReference RIGHT_ARROW destinationNodeTypeReference
   ;

abbreviatedEdgeTypePatternPointingLeft
   : destinationNodeTypeReference LEFT_ARROW sourceNodeTypeReference
   ;

abbreviatedEdgeTypePatternUndirected
   : sourceNodeTypeReference TILDE destinationNodeTypeReference
   ;

nodeTypeReference
   : sourceNodeTypeReference
   | destinationNodeTypeReference
   ;

sourceNodeTypeReference
   : LEFT_PAREN sourceNodeTypeName RIGHT_PAREN
   | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
   ;

destinationNodeTypeReference
   : LEFT_PAREN destinationNodeTypeName RIGHT_PAREN
   | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
   ;

edgeKind
   : 'DIRECTED'
   | 'UNDIRECTED'
   ;

endpointDefinition
   : 'CONNECTING' endpointPairDefinition
   ;

endpointPairDefinition
   : endpointPairDefinitionPointingRight
   | endpointPairDefinitionPointingLeft
   | endpointPairDefinitionUndirected
   | abbreviatedEdgeTypePattern
   ;

endpointPairDefinitionPointingRight
   : LEFT_PAREN sourceNodeTypeName connectorPointingRight destinationNodeTypeName RIGHT_PAREN
   ;

endpointPairDefinitionPointingLeft
   : LEFT_PAREN destinationNodeTypeName LEFT_ARROW sourceNodeTypeName RIGHT_PAREN
   ;

endpointPairDefinitionUndirected
   : LEFT_PAREN sourceNodeTypeName connectorUndirected destinationNodeTypeName RIGHT_PAREN
   ;

connectorPointingRight
   : 'TO'
   | RIGHT_ARROW
   ;

connectorUndirected
   : 'TO'
   | TILDE
   ;

sourceNodeTypeName
   : ELEMENT_TYPE_NAME
   ;

destinationNodeTypeName
   : ELEMENT_TYPE_NAME
   ;

labelSetDefinition
   : 'LABEL' LABEL_NAME
   | 'LABELS' labelSetSpecification
   | isOrColon labelSetSpecification
   ;

propertyTypeSetDefinition
   : LEFT_BRACE propertyTypeDefinitionList? RIGHT_BRACE
   ;

propertyTypeDefinitionList
   : propertyTypeDefinition (COMMA propertyTypeDefinition)*
   ;

propertyTypeDefinition
   : PROPERTY_NAME typed? propertyValueType
   ;

propertyValueType
   : valueType
   ;

bindingTableType
   : 'BINDING'? 'TABLE' fieldTypesSpecification
   ;

valueType
   : predefinedType
   | constructedValueType
   | dynamicUnionType
   ;

typed
   : DOUBLE_COLON
   | 'TYPED'
   ;

predefinedType
   : booleanType
   | characterStringType
   | byteStringType
   | numericType
   | temporalType
   | referenceValueType
   ;

booleanType
   : ('BOOL' | 'BOOLEAN') notNull?
   ;

characterStringType
   : ('STRING' | 'VARCHAR') (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
   ;

byteStringType
   : 'BYTES' (LEFT_PAREN (minLength COMMA)? maxLength RIGHT_PAREN)? notNull?
   | 'BINARY' (LEFT_PAREN fixedLength RIGHT_PAREN)? notNull?
   | 'VARBINARY' (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
   ;

minLength
   : UNSIGNED_INTEGER
   ;

maxLength
   : UNSIGNED_INTEGER
   ;

fixedLength
   : UNSIGNED_INTEGER
   ;

numericType
   : exactNumericType
   | approximateNumericType
   ;

exactNumericType
   : binaryExactNumericType
   | decimalExactNumericType
   ;

binaryExactNumericType
   : signedBinaryExactNumericType
   | unsignedBinaryExactNumericType
   ;

signedBinaryExactNumericType
   : 'INT8' notNull?
   | 'INT16' notNull?
   | 'INT32' notNull?
   | 'INT64' notNull?
   | 'INT128' notNull?
   | 'INT256' notNull?
   | 'SMALLINT' notNull?
   | 'INT' (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | 'BIGINT'
   | 'SIGNED'? verboseBinaryExactNumericType notNull?
   ;

unsignedBinaryExactNumericType
   : 'UINT8' notNull?
   | 'UINT16' notNull?
   | 'UINT32' notNull?
   | 'UINT64' notNull?
   | 'UINT128' notNull?
   | 'UINT256' notNull?
   | 'USMALLINT' notNull?
   | 'UINT' (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | 'UBIGINT' notNull?
   | 'UNSIGNED' verboseBinaryExactNumericType notNull?
   ;

verboseBinaryExactNumericType
   : 'INTEGER8' notNull?
   | 'INTEGER16' notNull?
   | 'INTEGER32' notNull?
   | 'INTEGER64' notNull?
   | 'INTEGER128' notNull?
   | 'INTEGER256' notNull?
   | 'SMALL' 'INTEGER' notNull?
   | 'INTEGER' (LEFT_PAREN precision RIGHT_PAREN)? notNull?
   | 'BIG' 'INTEGER' notNull?
   ;

decimalExactNumericType
   : ('DECIMAL' | 'DEC') (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN notNull?)?
   ;

precision
   : UNSIGNED_DECIMAL_INTEGER
   ;

scale
   : UNSIGNED_DECIMAL_INTEGER
   ;

approximateNumericType
   : 'FLOAT16' notNull?
   | 'FLOAT32' notNull?
   | 'FLOAT64' notNull?
   | 'FLOAT128' notNull?
   | 'FLOAT256' notNull?
   | 'FLOAT' (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN)? notNull?
   | 'REAL' notNull?
   | 'DOUBLE' 'PRECISION'? notNull?
   ;

temporalType
   : temporalInstantType
   | temporalDurationType
   ;

temporalInstantType
   : datetimeType
   | localdatetimeType
   | dateType
   | timeType
   | localtimeType
   ;

temporalDurationType
   : durationType
   ;

datetimeType
   : 'ZONED' 'DATETIME' notNull?
   | 'TIMESTAMP' 'WITH' 'TIME' 'ZONE' notNull?
   ;

localdatetimeType
   : 'LOCAL' 'DATETIME' notNull?
   | 'TIMESTAMP' ('WITHOUT' 'TIME' 'ZONE')? notNull?
   ;

dateType
   : 'DATE' notNull?
   ;

timeType
   : 'ZONED' 'TIME' notNull?
   | 'TIME' 'WITH' 'TIME' 'ZONE' notNull?
   ;

localtimeType
   : 'LOCAL' 'TIME' notNull?
   | 'TIME' 'WITHOUT' 'TIME' 'ZONE' notNull?
   ;

durationType
   : 'DURATION' notNull?
   ;

referenceValueType
   : graphReferenceValueType
   | bindingTableReferenceValueType
   | nodeReferenceValueType
   | edgeReferenceValueType
   ;

graphReferenceValueType
   : openGraphReferenceValueType
   | closedGraphReferenceValueType
   ;

closedGraphReferenceValueType
   : 'PROPERTY'? 'GRAPH' nestedGraphTypeSpecification notNull?
   ;

openGraphReferenceValueType
   : 'ANY' 'PROPERTY'? 'GRAPH' notNull?
   ;

bindingTableReferenceValueType
   : bindingTableType notNull?
   ;

nodeReferenceValueType
   : openNodeReferenceValueType
   | closedNodeReferenceValueType
   ;

closedNodeReferenceValueType
   : nodeTypeDefinition notNull?
   ;

openNodeReferenceValueType
   : 'ANY'? NODE_SYNONYM notNull?
   ;

edgeReferenceValueType
   : openEdgeReferenceValueType
   | closedEdgeReferenceValueType
   ;

closedEdgeReferenceValueType
   : edgeTypeDefinition notNull?
   ;

openEdgeReferenceValueType
   : 'ANY'? EDGE_SYNONYM notNull?
   ;

constructedValueType
   : pathValueType
   | listValueType
   | recordType
   ;

pathValueType
   : 'PATH' notNull?
   ;

listValueType
   : (listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET | valueType listValueTypeName) (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?
   ;

listValueTypeName
   : 'GROUP'? listValueTypeNameSynonym
   ;

listValueTypeNameSynonym
   : 'LIST'
   | 'ARRAY'
   ;

recordType
   : 'ANY'? 'RECORD' notNull?
   | 'RECORD'? fieldTypesSpecification notNull?
   ;

fieldTypesSpecification
   : LEFT_BRACE fieldTypeList? RIGHT_BRACE
   ;

fieldTypeList
   : fieldType (COMMA fieldType)*
   ;

dynamicUnionType
   : openDynamicUnionType
   | dynamicPropertyValueType
   | closedDynamicUnionType
   ;

openDynamicUnionType
   : 'ANY' 'VALUE'? notNull?
   ;

dynamicPropertyValueType
   : 'ANY'? 'PROPERTY' 'VALUE' notNull?
   ;

closedDynamicUnionType
   : 'ANY' 'VALUE'? LEFT_ANGLE_BRACKET componentTypeList RIGHT_ANGLE_BRACKET
   | componentTypeList
   ;

componentTypeList
   : componentType (VERTICAL_BAR componentType)*
   ;

componentType
   : valueType
   ;

notNull
   : ' NOT' 'NULL'
   ;

fieldType
   : FIELD_NAME typed? valueType
   ;

schemaReference
   : absoluteCatalogSchemaReference
   | relativeCatalogSchemaReference
   | referenceParameter
   ;

absoluteCatalogSchemaReference
   : SOLIDUS
   | absoluteDirectoryPath SCHEMA_NAME
   ;

catalogSchemaParentAndName
   : absoluteDirectoryPath SCHEMA_NAME
   ;

relativeCatalogSchemaReference
   : predefinedSchemaReference
   | relativeDirectoryPath SCHEMA_NAME
   ;

predefinedSchemaReference
   : 'HOME_SCHEMA'
   | 'CURRENT_SCHEMA'
   | PERIOD
   ;

absoluteDirectoryPath
   : SOLIDUS simpleDirectoryPath?
   ;

relativeDirectoryPath
   : DOUBLE_PERIOD ( (SOLIDUS DOUBLE_PERIOD)+ SOLIDUS simpleDirectoryPath?)?
   ;

simpleDirectoryPath
   : (DIRECTORY_NAME SOLIDUS)+
   ;

graphReference
   : catalogObjectParentReference GRAPH_NAME
   | DELIMITED_GRAPH_NAME
   | homeGraph
   | referenceParameter
   ;

catalogGraphParentAndName
   : catalogObjectParentReference? GRAPH_NAME
   ;

homeGraph
   : 'HOME_PROPERTY_GRAPH'
   | 'HOME_GRAPH'
   ;

graphTypeReference
   : catalogGraphTypeParentAndName
   | referenceParameter
   ;

catalogGraphTypeParentAndName
   : catalogObjectParentReference? GRAPH_TYPE_NAME
   ;

bindingTableReference
   : catalogObjectParentReference BINDING_TABLE_NAME
   | DELIMITED_BINDING_TABLE_NAME
   | referenceParameter
   ;

catalogBindingTableParentAndName
   : catalogObjectParentReference? BINDING_TABLE_NAME
   ;

procedureReference
   : catalogProcedureParentAndName
   | referenceParameter
   ;

catalogProcedureParentAndName
   : catalogObjectParentReference? PROCEDURE_NAME
   ;

catalogObjectParentReference
   : schemaReference SOLIDUS? (OBJECT_NAME PERIOD)*
   |  (OBJECT_NAME PERIOD)+
   ;

referenceParameter
   : parameter
   ;

externalObjectReference
   : seeTheRules
   ;

searchCondition
   : booleanValueExpression
   ;

predicate
   : comparisonPredicate
   | existsPredicate
   | nullPredicate
   | normalizedPredicate
   | directedPredicate
   | labeledPredicate
   | sourceDestinationPredicate
   | all_differentPredicate
   | samePredicate
   | property_existsPredicate
   ;

comparisonPredicate
   : comparisonPredicand comparisonPredicatePart2
   ;

comparisonPredicatePart2
   : compOp comparisonPredicand
   ;

compOp
   : EQUALS_OPERATOR
   | NOT_EQUALS_OPERATOR
   | LESS_THAN_OPERATOR
   | GREATER_THAN_OPERATOR
   | LESS_THAN_OR_EQUALS_OPERATOR
   | GREATER_THAN_OR_EQUALS_OPERATOR
   ;

comparisonPredicand
   : commonValueExpression
   | booleanPredicand
   ;

existsPredicate
   : 'EXISTS' (LEFT_BRACE graphPattern RIGHT_BRACE | LEFT_PAREN graphPattern RIGHT_PAREN | LEFT_BRACE matchStatementBlock RIGHT_BRACE | LEFT_PAREN matchStatementBlock RIGHT_PAREN | nestedQuerySpecification)
   ;

nullPredicate
   : valueExpressionPrimary nullPredicatePart2
   ;

nullPredicatePart2
   : 'IS' 'NOT'? 'NULL'
   ;

valueTypePredicate
   : valueExpressionPrimary valueTypePredicatePart2
   ;

valueTypePredicatePart2
   : 'IS' 'NOT'? typed valueType
   ;

normalizedPredicate
   : stringValueExpression normalizedPredicatePart2
   ;

normalizedPredicatePart2
   : 'IS' 'NOT'? normalForm? 'NORMALIZED'
   ;

directedPredicate
   : elementVariableReference directedPredicatePart2
   ;

directedPredicatePart2
   : 'IS' 'NOT'? 'DIRECTED'
   ;

labeledPredicate
   : elementVariableReference labeledPredicatePart2
   ;

labeledPredicatePart2
   : isLabeledOrColon labelExpression
   ;

isLabeledOrColon
   : 'IS' 'NOT'? 'LABELED'
   | COLON
   ;

sourceDestinationPredicate
   : nodeReference sourcePredicatePart2
   | nodeReference destinationPredicatePart2
   ;

nodeReference
   : elementVariableReference
   ;

sourcePredicatePart2
   : 'IS' 'NOT'? 'SOURCE' 'OF' edgeReference
   ;

destinationPredicatePart2
   : 'IS' 'NOT'? 'DESTINATION' 'OF' edgeReference
   ;

edgeReference
   : elementVariableReference
   ;

all_differentPredicate
   : 'ALL_DIFFERENT' LEFT_PAREN elementVariableReference COMMA elementVariableReference (COMMA elementVariableReference)* RIGHT_PAREN
   ;

samePredicate
   : 'SAME' LEFT_PAREN elementVariableReference COMMA elementVariableReference (COMMA elementVariableReference)* RIGHT_PAREN
   ;

property_existsPredicate
   : 'PROPERTY_EXISTS' LEFT_PAREN elementVariableReference COMMA PROPERTY_NAME RIGHT_PAREN
   ;

valueSpecification
   : literal
   | parameterValueSpecification
   ;

unsignedValueSpecification
   : unsignedLiteral
   | parameterValueSpecification
   ;

unsignedIntegerSpecification
   : UNSIGNED_INTEGER
   | parameter
   ;

parameterValueSpecification
   : parameter
   | predefinedParameter
   ;

predefinedParameter
   : 'CURRENT_USER'
   ;

valueExpression
   : commonValueExpression
   | booleanValueExpression
   ;

commonValueExpression
   : numericValueExpression
   | stringValueExpression
   | datetimeValueExpression
   | durationValueExpression
   | listValueExpression
   | recordValueExpression
   | pathValueExpression
   | referenceValueExpression
   ;

referenceValueExpression
   : graphReferenceValueExpression
   | bindingTableReferenceValueExpression
   | nodeReferenceValueExpression
   | edgeReferenceValueExpression
   ;

graphReferenceValueExpression
   : 'PROPERTY'? 'GRAPH' graphExpression
   | valueExpressionPrimary
   ;

bindingTableReferenceValueExpression
   : 'BINDING'? 'TABLE' bindingTableExpression
   | valueExpressionPrimary
   ;

nodeReferenceValueExpression
   : valueExpressionPrimary
   ;

edgeReferenceValueExpression
   : valueExpressionPrimary
   ;

recordValueExpression
   : valueExpressionPrimary
   ;

aggregatingValueExpression
   : valueExpression
   ;

booleanValueExpression
   : booleanTerm
   | booleanValueExpression 'OR' booleanTerm
   | booleanValueExpression 'XOR' booleanTerm
   ;

booleanTerm
   : booleanFactor
   | booleanTerm 'AND' booleanFactor
   ;

booleanFactor
   : 'NOT'? booleanTest
   ;

booleanTest
   : booleanPrimary ('IS' 'NOT'? truthValue)?
   ;

truthValue
   : 'TRUE'
   | 'FALSE'
   | 'UNKNOWN'
   ;

booleanPrimary
   : predicate
   | booleanPredicand
   ;

booleanPredicand
   : parenthesizedBooleanValueExpression
   | nonParenthesizedValueExpressionPrimary
   ;

parenthesizedBooleanValueExpression
   : LEFT_PAREN booleanValueExpression RIGHT_PAREN
   ;

numericValueExpression
   : term
   | numericValueExpression PLUS_SIGN term
   | numericValueExpression MINUS_SIGN term
   ;

term
   : factor
   | term ASTERISK factor
   | term SOLIDUS factor
   ;

factor
   : SIGN? numericPrimary
   ;

numericPrimary
   : valueExpressionPrimary
   | numericValueFunction
   ;

valueExpressionPrimary
   : parenthesizedValueExpression
   | nonParenthesizedValueExpressionPrimary
   ;

parenthesizedValueExpression
   : LEFT_PAREN valueExpression RIGHT_PAREN
   ;

nonParenthesizedValueExpressionPrimary
   : nonParenthesizedValueExpressionPrimarySpecialCase
   | bindingVariableReference
   ;

nonParenthesizedValueExpressionPrimarySpecialCase
   : propertyReference
   | unsignedValueSpecification
   | aggregateFunction
   | collectionValueConstructor
   | valueQueryExpression
   | caseExpression
   | letValueExpression
   | castSpecification
   | element_idFunction
   ;

collectionValueConstructor
   : listValueConstructor
   | recordValueConstructor
   | pathValueConstructor
   ;

numericValueFunction
   : lengthExpression
   | absoluteValueExpression
   | modulusExpression
   | trigonometricFunction
   | generalLogarithmFunction
   | commonLogarithm
   | naturalLogarithm
   | exponentialFunction
   | powerFunction
   | squareRoot
   | floorFunction
   | ceilingFunction
   ;

lengthExpression
   : charLengthExpression
   | byteLengthExpression
   | pathLengthExpression
   ;

charLengthExpression
   : ('CHAR_LENGTH' | 'CHARACTER_LENGTH') LEFT_PAREN characterStringValueExpression RIGHT_PAREN
   ;

byteLengthExpression
   : ('BYTE_LENGTH' | 'OCTET_LENGTH') LEFT_PAREN byteStringValueExpression RIGHT_PAREN
   ;

pathLengthExpression
   : 'PATH_LENGTH' LEFT_PAREN pathValueExpression RIGHT_PAREN
   ;

absoluteValueExpression
   : 'ABS' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

modulusExpression
   : 'MOD' LEFT_PAREN numericValueExpressionDividend COMMA numericValueExpressionDivisor RIGHT_PAREN
   ;

numericValueExpressionDividend
   : numericValueExpression
   ;

numericValueExpressionDivisor
   : numericValueExpression
   ;

trigonometricFunction
   : trigonometricFunctionName LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

trigonometricFunctionName
   : 'SIN'
   | 'COS'
   | 'TAN'
   | 'COT'
   | 'SINH'
   | 'COSH'
   | 'TANH'
   | 'ASIN'
   | 'ACOS'
   | 'ATAN'
   | 'DEGREES'
   | 'RADIANS'
   ;

generalLogarithmFunction
   : 'LOG' LEFT_PAREN generalLogarithmBase COMMA generalLogarithmArgument RIGHT_PAREN
   ;

generalLogarithmBase
   : numericValueExpression
   ;

generalLogarithmArgument
   : numericValueExpression
   ;

commonLogarithm
   : 'LOG10' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

naturalLogarithm
   : 'LN' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

exponentialFunction
   : 'EXP' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

powerFunction
   : 'POWER' LEFT_PAREN numericValueExpressionBase COMMA numericValueExpressionExponent RIGHT_PAREN
   ;

numericValueExpressionBase
   : numericValueExpression
   ;

numericValueExpressionExponent
   : numericValueExpression
   ;

squareRoot
   : 'SQRT' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

floorFunction
   : 'FLOOR' LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

ceilingFunction
   : ('CEIL' | 'CEILING') LEFT_PAREN numericValueExpression RIGHT_PAREN
   ;

stringValueExpression
   : characterStringValueExpression
   | byteStringValueExpression
   ;

characterStringValueExpression
   : characterStringConcatenation
   | characterStringFactor
   ;

characterStringConcatenation
   : characterStringValueExpression CONCATENATION_OPERATOR characterStringFactor
   ;

characterStringFactor
   : characterStringPrimary
   ;

characterStringPrimary
   : valueExpressionPrimary
   | stringValueFunction
   ;

byteStringValueExpression
   : byteStringConcatenation
   | byteStringFactor
   ;

byteStringFactor
   : byteStringPrimary
   ;

byteStringPrimary
   : valueExpressionPrimary
   | stringValueFunction
   ;

byteStringConcatenation
   : byteStringValueExpression CONCATENATION_OPERATOR byteStringFactor
   ;

stringValueFunction
   : characterStringFunction
   | byteStringFunction
   ;

characterStringFunction
   : substringFunction
   | fold
   | trimFunction
   | normalizeFunction
   ;

substringFunction
   : ('LEFT' | 'RIGHT') LEFT_PAREN characterStringValueExpression COMMA stringLength RIGHT_PAREN
   ;

fold
   : ('UPPER' | 'LOWER') LEFT_PAREN characterStringValueExpression RIGHT_PAREN
   ;

trimFunction
   : singleCharacterTrimFunction
   | multiCharacterTrimFunction
   ;

singleCharacterTrimFunction
   : 'TRIM' LEFT_PAREN trimOperands RIGHT_PAREN
   ;

multiCharacterTrimFunction
   : ('BTRIM' | 'LTRIM' | 'RTRIM') LEFT_PAREN trimSource (COMMA trimCharacterString)? RIGHT_PAREN
   ;

trimOperands
   : (trimSpecification? trimCharacterString? 'FROM')? trimSource
   ;

trimSource
   : characterStringValueExpression
   ;

trimSpecification
   : 'LEADING'
   | 'TRAILING'
   | 'BOTH'
   ;

trimCharacterString
   : characterStringValueExpression
   ;

normalizeFunction
   : 'NORMALIZE' LEFT_PAREN characterStringValueExpression (COMMA normalForm)? RIGHT_PAREN
   ;

normalForm
   : 'NFC'
   | 'NFD'
   | 'NFKC'
   | 'NFKD'
   ;

byteStringFunction
   : byteStringSubstringFunction
   | byteStringTrimFunction
   ;

byteStringSubstringFunction
   : ('LEFT' | 'RIGHT') LEFT_PAREN byteStringValueExpression COMMA stringLength RIGHT_PAREN
   ;

byteStringTrimFunction
   : 'TRIM' LEFT_PAREN byteStringTrimOperands RIGHT_PAREN
   ;

byteStringTrimOperands
   : (trimSpecification? trimByteString? 'FROM')? byteStringTrimSource
   ;

byteStringTrimSource
   : byteStringValueExpression
   ;

trimByteString
   : byteStringValueExpression
   ;

stringLength
   : numericValueExpression
   ;

datetimeValueExpression
   : datetimeTerm
   | durationValueExpression PLUS_SIGN datetimeTerm
   | datetimeValueExpression PLUS_SIGN durationTerm
   | datetimeValueExpression MINUS_SIGN durationTerm
   ;

datetimeTerm
   : datetimeFactor
   ;

datetimeFactor
   : datetimePrimary
   ;

datetimePrimary
   : valueExpressionPrimary
   | datetimeValueFunction
   ;

datetimeValueFunction
   : dateFunction
   | timeFunction
   | datetimeFunction
   | localTimeFunction
   | localDatetimeFunction
   ;

dateFunction
   : 'CURRENT_DATE'
   | 'DATE' LEFT_PAREN dateFunctionParameters? RIGHT_PAREN
   ;

timeFunction
   : 'CURRENT_TIME'
   | 'ZONED_TIME' LEFT_PAREN timeFunctionParameters? RIGHT_PAREN
   ;

localTimeFunction
   : 'LOCAL_TIME' (LEFT_PAREN timeFunctionParameters? RIGHT_PAREN)?
   ;

datetimeFunction
   : 'CURRENT_TIMESTAMP'
   | 'ZONED_DATETIME' LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
   ;

localDatetimeFunction
   : 'LOCAL_TIMESTAMP'
   | 'LOCAL_DATETIME' LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
   ;

dateFunctionParameters
   : DATE_STRING
   | recordValueConstructor
   ;

timeFunctionParameters
   : TIME_STRING
   | recordValueConstructor
   ;

datetimeFunctionParameters
   : DATETIME_STRING
   | recordValueConstructor
   ;

durationValueExpression
   : durationTerm
   | durationValueExpression1 PLUS_SIGN durationTerm1
   | durationValueExpression1 MINUS_SIGN durationTerm1
   | datetimeSubtraction
   ;

datetimeSubtraction
   : 'DURATION_BETWEEN' LEFT_PAREN datetimeSubtractionParameters RIGHT_PAREN
   ;

datetimeSubtractionParameters
   : datetimeValueExpression1 COMMA datetimeValueExpression2
   ;

durationTerm
   : durationFactor
   | durationTerm2 ASTERISK factor
   | durationTerm2 SOLIDUS factor
   | term ASTERISK durationFactor
   ;

durationFactor
   : SIGN? durationPrimary
   ;

durationPrimary
   : valueExpressionPrimary
   | durationValueFunction
   ;

durationValueExpression1
   : durationValueExpression
   ;

durationTerm1
   : durationTerm
   ;

durationTerm2
   : durationTerm
   ;

datetimeValueExpression1
   : datetimeValueExpression
   ;

datetimeValueExpression2
   : datetimeValueExpression
   ;

durationValueFunction
   : durationFunction
   | durationAbsoluteValueFunction
   ;

durationFunction
   : 'DURATION' LEFT_PAREN durationFunctionParameters RIGHT_PAREN
   ;

durationFunctionParameters
   : DURATION_STRING
   | recordValueConstructor
   ;

durationAbsoluteValueFunction
   : 'ABS' LEFT_PAREN durationValueExpression RIGHT_PAREN
   ;

listValueExpression
   : listConcatenation
   | listPrimary
   ;

listConcatenation
   : listValueExpression1 CONCATENATION_OPERATOR listPrimary
   ;

listValueExpression1
   : listValueExpression
   ;

listPrimary
   : listValueFunction
   | valueExpressionPrimary
   ;

listValueFunction
   : trimListFunction
   | elementsFunction
   ;

trimListFunction
   : 'TRIM' LEFT_PAREN listValueExpression COMMA numericValueExpression RIGHT_PAREN
   ;

elementsFunction
   : 'ELEMENTS' LEFT_PAREN pathValueExpression RIGHT_PAREN
   ;

listValueConstructor
   : listValueConstructorByEnumeration
   ;

listValueConstructorByEnumeration
   : listValueTypeName? LEFT_BRACKET listElementList? RIGHT_BRACKET
   ;

listElementList
   : listElement (COMMA listElement)*
   ;

listElement
   : valueExpression
   ;

recordValueConstructor
   : 'RECORD'? fieldsSpecification
   ;

fieldsSpecification
   : LEFT_BRACE fieldList? RIGHT_BRACE
   ;

fieldList
   : field (COMMA field)*
   ;

field
   : FIELD_NAME COLON valueExpression
   ;

pathValueExpression
   : pathValueConcatenation
   | pathValuePrimary
   ;

pathValueConcatenation
   : pathValueExpression1 CONCATENATION_OPERATOR pathValuePrimary
   ;

pathValueExpression1
   : pathValueExpression
   ;

pathValuePrimary
   : valueExpressionPrimary
   ;

pathValueConstructor
   : pathValueConstructorByEnumeration
   ;

pathValueConstructorByEnumeration
   : 'PATH' LEFT_BRACKET pathElementList RIGHT_BRACKET
   ;

pathElementList
   : pathElementListStart pathElementListStep*
   ;

pathElementListStart
   : nodeReferenceValueExpression
   ;

pathElementListStep
   : COMMA edgeReferenceValueExpression COMMA nodeReferenceValueExpression
   ;

propertyReference
   : propertySource PERIOD PROPERTY_NAME
   ;

propertySource
   : nodeReferenceValueExpression
   | edgeReferenceValueExpression
   | recordValueExpression
   ;

valueQueryExpression
   : 'VALUE' nestedQuerySpecification
   ;

caseExpression
   : caseAbbreviation
   | caseSpecification
   ;

caseAbbreviation
   : 'NULLIF' LEFT_PAREN valueExpression COMMA valueExpression RIGHT_PAREN
   | 'COALESCE' LEFT_PAREN valueExpression (COMMA valueExpression)+ RIGHT_PAREN
   ;

caseSpecification
   : simpleCase
   | searchedCase
   ;

simpleCase
   : 'CASE' caseOperand simpleWhenClause+ elseClause? 'END'
   ;

searchedCase
   : 'CASE' searchedWhenClause+ elseClause? 'END'
   ;

simpleWhenClause
   : 'WHEN' whenOperandList 'THEN' result
   ;

searchedWhenClause
   : 'WHEN' searchCondition 'THEN' result
   ;

elseClause
   : 'ELSE' result
   ;

caseOperand
   : nonParenthesizedValueExpressionPrimary
   | elementVariableReference
   ;

whenOperandList
   : whenOperand (COMMA whenOperand)*
   ;

whenOperand
   : nonParenthesizedValueExpressionPrimary
   | comparisonPredicatePart2
   | nullPredicatePart2
   | valueTypePredicatePart2
   | directedPredicatePart2
   | labeledPredicatePart2
   | sourcePredicatePart2
   | destinationPredicatePart2
   ;

result
   : resultExpression
   | 'NULL'
   ;

resultExpression
   : valueExpression
   ;

castSpecification
   : 'CAST' LEFT_PAREN castOperand 'AS' castTarget RIGHT_PAREN
   ;

castOperand
   : valueExpression
   ;

castTarget
   : valueType
   ;

element_idFunction
   : 'ELEMENT_ID' LEFT_PAREN elementVariableReference RIGHT_PAREN
   ;

letValueExpression
   : 'LET' letVariableDefinitionList 'IN' valueExpression 'END'
   ;

literal
   : SIGNED_NUMERIC_LITERAL
   | generalLiteral
   ;

generalLiteral
   : predefinedTypeLiteral
   | listLiteral
   | recordLiteral
   ;

predefinedTypeLiteral
   : BOOLEAN_LITERAL
   | CHARACTER_STRING_LITERAL
   | BYTE_STRING_LITERAL
   | TEMPORAL_LITERAL
   | DURATION_LITERAL
   | NULL_LITERAL
   ;

unsignedLiteral
   : UNSIGNED_NUMERIC_LITERAL
   | generalLiteral
   ;

listLiteral
   : listValueConstructorByEnumeration
   ;

recordLiteral
   : recordValueConstructor
   ;

