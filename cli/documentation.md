CMD interface
--------------

### Use cases of this interface:
--------------

1- used by users instead of GUI.

2- used by GPT to create architectures

### commands:
---------

1- user

   `aino create_user user_name password` # create a new user, replace if exists
   
   `aino load_user user_name password`   # load an existing user
   
2- projects

   `aino create_project project_name`    # create project, replace if exists
   
   `aino select_project project_name`    # for exisiting one
   
   `aino deselect_project`               # deselect project to select another one
   
   `aino list_projects`
   
   `aino load_last_project`

3- workflow

   `aino create_workflow work_flow_name`
   
   `aino select_workflow workflow_name`  # select a certain workflow
   
   `aino deselect_workflow` 
   
   `aino list_workflows`
   
   `aino load_last_workflow`
   
   `aino finish_workflow`

4- blocks

   `aino make block_name ((ports_in),(ports_out)) ((param_name,value))`
   
   `aino edit block_name ((ports_in),(ports out)) ((param_name,value))`
   
   `aino list_blocks`

5- common commands

   `aino sync`
   
example:
-------------

### making a logistic regression model to predict iris dataset
```aino load_user admin admin```
> User admin loaded.

```aino list_projects```
>Projects: 

```aino create_project prj1```
>Project prj1 created.

```aino list_projects```
>Projects: prj1

```aino select_project prj1```
>Project prj1 selected.

```aino list_workflows```
>Workflows: 

```aino create_workflow logestic_regression_workflow```
>Workflow logestic_regression_workflow created.

```aino list_workflows```
>Workflows: logestic_regression_workflow

```aino select_workflow logestic_regression_workflow```
>Workflow logestic_regression_workflow selected.

```aino list_blocks```
>Blocks: 

```aino make load_iris ((),('port1')) (())```
>Block load_iris created with ports ((),(port1)) and params (()).

```aino make train_test_split1 (('port1'),('port2','port3')) (('test_size',0.2),('random_state',42),('features_name','data'))```
>Block train_test_split1 created with ports ((port1),(port2,port3)) and params (('test_size',0.2),('random_state',42),('features_name','data')).

```aino make train_test_split2 (('port1'),('port4','port5')) (('test_size',0.2),('random_state',42),('features_name','target'))```
>Block train_test_split2 created with ports ((port1),(port4,port5)) and params (('test_size',0.2),('random_state',42),('features_name','target')).

```aino make standard_scaler ((),('port6')) (())```
>Block standard_scaler created with ports ((),(port6)) and params (()).

```aino make fit_transform (('port6','port2'),'port7') (())```
>Block fit_transform created with ports ((port6,port2),port7) and params (()).

```aino make transform (('port3'),('port8')) (())```
>Block transform created with ports ((port3),(port8)) and params (()).

```aino make logestic_regression ((),('port9')) (())```
>Block logestic_regression created with ports ((),(port9)) and params (()).

```aino make fit (('port9','port7','port4'),('port10')) (())```
>Block fit created with ports ((port9,port7,port4),(port10)) and params (()).

```aino make predict (('port10','port8'),('port11')) (())```
>Block predict created with ports ((port10,port8),(port11)) and params (()).

```aino make accurac_score (('port11','port5'),()) (())```
>Block accurac_score created with ports ((port11,port5),()) and params (()).

```aino list_blocks```
>Blocks: load_iris, train_test_split1, train_test_split2, standard_scaler, fit_transform, transform, logestic_regression, fit, predict, accurac_score

```aino finish_workflow```
>workflow finished...


