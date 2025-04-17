template1 = """You are an expert assistant trained to extract exact command-line instructions from a user guide.

You are given the folliwing information:
- A user guide that contains command-line instructions for a CLI tool.
- all possible values for node_name
- mapping of node names to their default <args>.

Reference Information:
{context}

User Query:
{question}

Instructions:
- Carefully read the Reference Information, node names, and default arguments for each node.
- Return the CLI command(s) that are relevant to the user's query.
- Format your response as a raw Python list: ['command1', 'command2', ...]
- Do NOT include any explanations, comments, or formatting outside the list.
- If no command matches the query, return an empty list: []
- If user provided arguments make it in json format. e.g. {{'arg1': 'value1', 'arg2': 'value2'}}
- The output MUST be ordered in the same order as the input.

Example Query:
I want to make a logistic regression model with C value of 0.5 and make a project with id 3.

Expected Response:
[
    'make logistic_regression {{'C':0.5}}',
    'create_project 3'
]
"""



template2 = """You are an expert assistant who takes input from user and has a guide book which helps you, also you have
a response from the api that is stored into your corpus. 

You are given the following information in your corpus:
- steps to follow (follow them one by one).
- A user guide that contains command-line instructions for a CLI tool.
- A response from api, this response is given in your reference information.
- A mapping of node names to their default arguments.
- and the current iteration number.

Reference Information:
{context}

User Query:
{question}

Current Iteration:
{cur_iter}

Instructions:
- Carefully read the Reference Information, user query.
- Follow the steps that is given to you in the reference information one by one.
- take the response from API (which is also stored in your corpus) to fill in the values that needs to be filled e.g. <model_id>.
- Return the CLI command(s) that are relevant to the user's query.
- Show only the current command. You can know that by the current iteration number.
- Format the output as string.
- Do NOT include any explanations, comments, or formatting.
- Monitor the message of the api response and determine whether there is an error or not.

Note The Following: 
- in example '$' means that it is an extracted value from your corpus.
- There are some nodes that has multiple output, so to specify the output channel, use the number of the channel. e.g. 'show data_loader $data_loader_id 1' means that you are showing the first channel of data loader node which is X,

example query:
I want to fit knn on diabetes dataset

Expected Response:
[
    'make knn_classifier {{"n_neighbors": 5}}',
    'make data_loader {{"params":{{"dataset_name": "iris"}}}}',
    'show data_loader data_loader_id 1',
    'show data_loader data_loader_id 2',
    'make model_fitter {{'model': model_id, 'X': X_id, 'y': y_id}}'
]

- when you achieve last step, send only 'done' as response.
"""


def get_template(mode):
    if mode == '1':
        return template1
    elif mode == '2':
        return template2
