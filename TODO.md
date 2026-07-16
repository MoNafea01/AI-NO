- Thinking of removing the type and task from node model (we can extract them from component_id)
- Database vs Display ids for security and logic (Suggest adding field named 'order' for ordering projects, workflows & addind display_id as uuid for them as well)

- Making sure the flow is like this:
        - User Logs in (users)
        - Server Generates Refresh & Access token to the user to use it (refresh_token)
        - Server loads all Side Menu (category, component)
        - User Creates a Project (project)
        - User Adds a new tab (workflow)
        - User Drags & Drops a node from the side menu and connect it to another node (node)
        - User Runs the workflow (workflow_runs) -> Engine sort order of execution and run each node (execution_cache, workflow_steps)
        - User Saves the workflow as a checkpoint (workflow_snapshot)
        - User Modifies the workflow and rerun the workflow -> Engine arranges the nodes and checks the cache for each then determines which to re-run and its downstream.


Tested:
    - Components (Done)
    - Projects 

