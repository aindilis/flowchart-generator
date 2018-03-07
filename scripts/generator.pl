isa(bring,action).
isa(check_light,decisionPoint).

%% transition(StateID1,StateID2).
%% decisionPoint(DecisionPointID,StateID,Question).
%% result(DecisionPointID,true,'Yes').
%% result(DecisionPointID,false,'No').

renderFlowChart :-
	generateFlowchart([check_light(room5), if(occupied(room5), [bring(room6, room3), bring(room2, room6)], [bring(room2, room5), check_light(room3), if(occupied(room3), [bring(room6, room4)], [bring(room6, room3)])])],JPGImageFile),
	viewImageFile(JPGImageFile).

testRenderFlowChart :-
	mapFLUXContingentPlanToDotFormat([check_light(room5), if(occupied(room5), [bring(room6, room3), bring(room2, room6)], [bring(room2, room5), check_light(room3), if(occupied(room3), [bring(room6, room4)], [bring(room6, room3)])])],DotFileContents),
	view([dotFileContents,DotFileContents]).

generateFlowchart(FluxContingentPlan,JPGImageFile) :-
	mapFLUXContingentPlanToDotFormat(FluxContingentPlan,DotFileContents),
	DotFile = '/var/lib/myfrdcsa/codebases/minor/flowchart-generator/data-git/flp2.dot',
	write_data_to_file(DotFileContents,DotFile),
	renderDotFileToFlowchartImageFile(DotFile,'/var/lib/myfrdcsa/codebases/minor/flowchart-generator/data-git/flp2.png').

renderDotFileToFlowchartImageFile(DotFile,PNGImageFile) :-
	atomic_list_concat(['dot -Tpng -Gsize=18,30! -Gdpi=100 -o',PNGImageFile,' ',DotFile],' ',ShellCommand1),
	shell(ShellCommand1),
	shell('/var/lib/myfrdcsa/codebases/minor/flowchart-generator/data-git/perspective6.pl').

render(decisionPoint(DecisionPoint),Output) :-
	DecisionPoint = [StateID,Label,Options],
	atomic_list_concat([StateID,' [shape=diamond, label="',Label,'"];'],'',Output).

render(action(Action),Output) :-
	Action = [StateID,Label],
	atomic_list_concat([StateID,' [shape=box, label="',Label,'"];'],'',Output).

mapFLUXContingentPlanToDotFormat(FLUXContingentPlan,DotFileContents) :-
	mapFLUXContingentPlanToInterlingua(FLUXContingentPlan,Interlingua),
	view([interlingua,Interlingua]),
	mapInterlinguaToDotFileContents(Interlingua,DotFileContents).

%% mapFLUXContingentPlanToInterlingua(FLUXContingentPlan,Interlingua) :-
%% 	view([fluxContingentPlan,FLUXContingentPlan]),
%% 	findall(Assertion,
%% 		(   
%% 		    member(Step,FLUXContingentPlan),
%% 		    getName(Step,StepName),
%% 		    getLabel(Step,StepLabel),
%% 		    view([stepName,StepName,stepLabel,StepLabel]),

%% 		    Step =.. [Predicate|Args],
%% 		    (	(   Predicate = if) ->
%% 			(   
%% 			    Args = [Condition,TrueBranch,FalseBranch],
%% 			    getName(Condition,ConditionName),
%% 			    getLabel(Condition,ConditionLabel),

%% 			    mapFLUXContingentPlanToInterlingua(TrueBranch,TrueBranchAssertions),
%% 			    mapFLUXContingentPlanToInterlingua(FalseBranch,FalseBranchAssertions),

%% 			    TrueBranchAssertions = [FirstTrueBranchAssertion|_],
%% 			    getName(FirstTrueBranchAssertion,FirstTrueBranchAssertionName),

%% 			    FalseBranchAssertions = [FirstFalseBranchAssertion|_],
%% 			    getName(FirstFalseBranchAssertion,FirstFalseBranchAssertionName),

%% 			    TmpAssertions = [
%% 					     decisionPoint(ConditionName,ConditionLabel),
%% 					     labelledEdge(StepName,FirstTrueBranchAssertionName,'Yes'),
%% 					     labelledEdge(StepName,FirstFalseBranchAssertionName,'No')
%% 					    ],

%% 			    append([TmpAssertions,TrueBranchAssertions,FalseBranchAssertions],Assertions),
%% 			    member(Assertion,Assertions)
%% 			) ;
%% 			(
%% 			 Assertion = node(StepName,StepLabel),
%% 			 view([assertion,Assertion])
%% 			)
%% 		    )),
%% 		Interlingua),
%% 	view([interlingua,Ininterlingua]).
	
%% LABELED EDGE
%% foodPantry -> cellPhone [label="Yes"];

%% UNLABELED EDGE
%% start -> foodPantry;

%% NODE
%% soupKitchen [shape=box, label="Go to Soup Kitchen:\n443 Beecher Rd, Flint, MI 48503"];

%% DECISION POINT
%% ableToGetMeal [shape=diamond, label="Able to get warm meal?"];

mapInterlinguaToDotFileContents(Interlingua,DotFileContents) :-
	findall(Content,
		(   
		    member(Assertion,Interlingua),
		    view([assertion,Assertion]),
		    Assertion =.. [Predicate|Args],
		    view([predicate,Predicate,args,Args]),
		    (	(   Predicate = node) ->
			(   Args = [Node,Label],
			    atomic_list_concat([Node,' [shape=box, label="',Label,'"];'],'',Content)
			) ; 
			(   (	Predicate = decisionPoint ) ->
			    (	
				Args = [Node,Label],
				atomic_list_concat([Node,' [shape=diamond, label="',Label,'"];'],'',Content)
			    ) ; 
			    (	(   Predicate = unlabelledEdge ) ->
				(   
				    Args = [Node1,Node2],
				    atomic_list_concat([Node1,' -> ',Node2,';'],'',Content)
				) ; 
				(   (	Predicate = labelledEdge) ->
				    (	
					Args = [Node1,Node2,Label],
					atomic_list_concat([Node1,' -> ',Node2,' [label="',Label,'"];'],'',Content)
				    ) ;  (	
						Content = ''
					 )))))),
		Contents),
	view([contents,Contents]),
	append([['\t'],Contents],Tmp1Contents),
	atomic_list_concat(Tmp1Contents,'\n\t',Tmp2Contents),
	atomic_list_concat(['digraph {\n\trankdir = BT;',Tmp2Contents,'}'],'\n',DotFileContents).

getName(Term,Name) :-
	atom(Term),
	Name = Term,
	!.
getName(Term,Name) :-
	Term \= [],
	Term =.. [Predicate|Args],
	%% view([term,Term]),
	findall(ArgName,(member(Arg,Args),getName(Arg,ArgName)),ArgNames),
	%% view([predicate,Predicate]),
	(   (	Predicate = '[|]') -> 
	    (	List = ArgNames ) ;
	    (	append([[Predicate],ArgNames],List))),
	atomic_list_concat(List,'_',Name).

getLabel(Term,Label) :-
	with_output_to(atom(Label),write(Term)).



mapFLUXContingentPlanToInterlingua(FLUXContingentPlan,Interlingua) :-
	mapFLUXContingentPlanToInterlingua1(FLUXContingentPlan,Interlingua).

mapFLUXContingentPlanToInterlingua1(FLUXContingentPlan,Interlingua) :-
	squelch(FLUXContingentPlan),
	Interlingua =
	[
	 node(start,'Go to Food Pantry:\n1621 McCormick Dr, Flint, MI 48532'),
	 unlabelledEdge(start,foodPantry),
	 decisionPoint(foodPantry,'Able to get food?'),
	 labelledEdge(foodPantry,cellPhone,'Yes'),
	 labelledEdge(foodPantry,updateFoodPantryHours,'No'),
	 node(cellPhone,'Go to Locust Wireless:\n1823 McCormick Dr., Flint, MI 48532'),
	 node(updateFoodPantryHours,'Please update food pantry hours on form here:'),
	 unlabelledEdge(updateFoodPantryHours,soupKitchen),
	 node(soupKitchen,'Go to Soup Kitchen:\n443 Beecher Rd., Flint, MI 48503'),
	 unlabelledEdge(soupKitchen,ableToGetMeal),
	 decisionPoint(ableToGetMeal,'Able to get warm meal?'),
	 labelledEdge(ableToGetMeal,cellPhone,'Yes'),
	 labelledEdge(ableToGetMeal,goToMeijer,'No'),
	 node(goToMeijer,'Go to Meijer:\n2333 H. Holland, Flint, MI 45519'),
	 unlabelledEdge(cellPhone,ableToGetCellPhone),
	 decisionPoint(ableToGetCellPhone,'Able to get free cell phone?'),
	 labelledEdge(ableToGetCellPhone,callFLP,'Yes'),
	 node(callFLP,'Call the Free Life Planner 1-800-GET-HELP')
	].



mapFLUXContingentPlanToInterlingua2(FLUXContingentPlan,Interlingua) :-
	squelch(FLUXContingentPlan),
	Interlingua =
	[
	 node(verify_is_legit,'verify(Person,ServicePerson,isLegit(Bill))'),
	 decisionPoint(if_legit,'isLegit(Bill)'),
	 unlabelledEdge(verify_is_legit,if_legit),

	 node(negotiatePaymentPlan,'negotiate(Person,paymentPlanWith(ServicePerson,Person))'),
	 node(updateRecords,'update(recordsFn(Person,Bill,not(isLegit)))'),

	 labelledEdge(if_legit,negotiatePaymentPlan,'Yes'),
	 labelledEdge(if_legit,updateRecords,'No')

	 %% node(bring_room2_room6,'bring(room2,room6)'),
	 %% unlabelledEdge(bring_room6_room3,bring_room2_room6),

	 %% node(check_light_room3,'check_light(room3)'),
	 %% unlabelledEdge(bring_room2_room5,check_light_room3),

	 %% decisionPoint(if_occupied_room3,'occupied(room3)'),
	 %% unlabelledEdge(check_light_room3,if_occupied_room3),

	 %% node(bring_room6_room4,'bring(room6,room4)'),
	 %% node(bring_room6_room3_2,'bring(room6,room3)'),

	 %% labelledEdge(if_occupied_room3,bring_room6_room4,'Yes'),
	 %% labelledEdge(if_occupied_room3,bring_room6_room3_2,'No')
	].


mapFLUXContingentPlanToInterlingua3(FLUXContingentPlan,Interlingua) :-
	squelch(FLUXContingentPlan),
	Interlingua =
	[
	 node(check_light_room5,'check_light(room5)'),
	 decisionPoint(if_occupied_room5,'occupied(room5)'),
	 unlabelledEdge(check_light_room5,if_occupied_room5),

	 node(bring_room6_room3,'bring(room6,room3)'),
	 node(bring_room2_room5,'bring(room2,room5)'),

	 labelledEdge(if_occupied_room5,bring_room6_room3,'Yes'),
	 labelledEdge(if_occupied_room5,bring_room2_room5,'No'),

	 node(bring_room2_room6,'bring(room2,room6)'),
	 unlabelledEdge(bring_room6_room3,bring_room2_room6),

	 node(check_light_room3,'check_light(room3)'),
	 unlabelledEdge(bring_room2_room5,check_light_room3),

	 decisionPoint(if_occupied_room3,'occupied(room3)'),
	 unlabelledEdge(check_light_room3,if_occupied_room3),

	 node(bring_room6_room4,'bring(room6,room4)'),
	 node(bring_room6_room3_2,'bring(room6,room3)'),

	 labelledEdge(if_occupied_room3,bring_room6_room4,'Yes'),
	 labelledEdge(if_occupied_room3,bring_room6_room3_2,'No')
	].

%%%%%%%%%%%%%%%%%%%%%%%%%

%% [check_light(room5), if(occupied(room5), [bring(room6, room3), bring(room2, room6)], [bring(room2, room5), check_light(room3), if(occupied(room3), [bring(room6, room4)], [bring(room6, room3)])])]

%%%%%%%%%%%%%%%%%%%%%%%%%

%% mapFLUXContingentPlanToInterlingua(FLUXContingentPlan,Interlingua) :-
%% 	squelch(FLUXContingentPlan),
%% 	Interlingua =
%% 	[
%% 	 node(check_light_room5,'check_light(room5)'),
%% 	 decisionPoint(if_occupied_room5,'occupied(room5)'),
%% 	 unlabelledEdge(check_light_room5,if_occupied_room5),
%% 	 node(planA,'planA'),
%% 	 node(planB,'planB'),
%% 	 labelledEdge(if_occupied_room5,planA,'Yes'),
%% 	 labelledEdge(if_occupied_room5,planB,'No'),

%% 	 node(bring_room6_room3,'bring(room6,room3)'),
%% 	 unlabelledEdge(planA,bring_room6_room3),

%% 	 node(bring_room2_room6,'bring(room2,room6)'),
%% 	 unlabelledEdge(bring_room6_room3,bring_room2_room6),

%% 	 node(bring_room2_room5,'bring(room2,room5)'),
%% 	 unlabelledEdge(planB,bring_room2_room5)
%% 	].

%%%%%%%%%%%%%%%%%%%%%%%%%

%% generateFlowchartOrig(FluxContingentPlan,JPGImageFile) :-
%% 	mapFLUXContingentPlanToDotFormat(FluxContingentPlan,DotFileContents),
%% 	DotFile = '/tmp/render.dot',
%% 	write_data_to_file(DotFileContents,DotFile),
%% 	renderDotFileToFlowchartJPGImageFile(DotFile,JPGImageFile).

%% renderDotFileToFlowchartJPGImageFile(DotFile,JPGImageFile) :-
%% 	PNGImageFile = '/tmp/render.png',
%% 	renderDotFileToFlowchartPNGImageFile(DotFile,PNGImageFile),
%% 	convertImageFormat(PNGImageFile,JPGImageFile).

%% convertImageFormat(PNGImageFile,JPGImageFile) :-
%% 	JPGImageFile = '/tmp/render.jpg',
%% 	atomic_list_concat(['convert',PNGImageFile,JPGImageFile],' ',ShellCommand),
%% 	shell(ShellCommand).

%% renderDotFileToFlowchartPNGImageFile(DotFile,PNGImageFile) :-
%% 	atomic_list_concat(['dot -Tpng',DotFile,'-o',PNGImageFile],' ',ShellCommand),
%% 	shell(ShellCommand).

%% viewImageFile(JPGImageFile) :-
%% 	atomic_list_concat(['eog',JPGImageFile],' ',ShellCommand),
%% 	view([jpgImageFile,JPGImageFile]),
%% 	shell_command_async(ShellCommand,_).

%%%%%%%%%%%%%%%%%%%%%%%%%

%% getName(Term,Name) :-
%% 	Name = 'node1'.


	
%% /tmp/render.dot



%% getName(Term,Name) :-
%% 	with_output_to(string(TermString),write(Term)),
%% 	re_split("[^A-Za-z0-9]",TermString,Split,[]),
%% 	view([split,Split]),
%% 	atomic_list_concat(Split,"_",Name),
%% 	view([name,Name]).



%% start [label="Go to Food Pantry:\n1621 McCormick Dr, Flint, MI 48532"];

%% start -> foodPantry;

%% foodPantry [shape=diamond, label="Able to get food?"];

%% foodPantry -> cellPhone [label="Yes"];
%% foodPantry -> updateFoodPantryHours [label="No"];

%% cellPhone [shape=box, label="Go to Locust Wireless:\n1823 McCormick Dr, Flint, MI 48532"];
%% updateFoodPantryHours [shape=box, label="Please Update food pantry hours on form here:"];	
%% updateFoodPantryHours -> soupKitchen;
%% soupKitchen [shape=box, label="Go to Soup Kitchen:\n443 Beecher Rd, Flint, MI 48503"];

%% ableToGetMeal [shape=diamond, label="Able to get warm meal?"];

%% soupKitchen -> ableToGetMeal;
%% ableToGetMeal -> cellPhone [label="Yes"]

%% cellPhone -> ableToGetCellPhone;

%% ableToGetCellPhone [shape=diamond, label="Able to get free cell phone?"];

%% ableToGetCellPhone -> callFLP [label="Yes"];

%% callFLP [shape=box, label="Call the Free Life Planner 1-800-GET-HELP"];


%% goToMeijer [shape=box, label="Go to Meijer:\n2333 N. Holland, Flint, MI 45519"];

%% ableToGetMeal -> goToMeijer [label="No"];

%%%%%%%%%%%%%%%%%%%%%%%%%

%% [check_light(room5), if(occupied(room5), [bring(room6, room3), bring(room2, room6)], [bring(room2, room5), check_light(room3), if(occupied(room3), [bring(room6, room4)], [bring(room6, room3)])])]

%% %% ordset_union ordsets

%%%%%%%%%%%%%%%%%%%%%%%%%