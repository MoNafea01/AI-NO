import django, os, asyncio
from __init__ import *

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'project')))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "project.settings")
django.setup()

from fastapi import FastAPI, Query
from typing import Optional, Union
from chatbot.cb_utils import get_history, save_history, clear_history

from pydantic import BaseModel
from cli.call_cli import call_script
from chatbot.utils import process_query
from chatbot.core.utils import init_logger, load_config


config = load_config('config/config.yaml')
logger = init_logger(__name__, config)

app = FastAPI()

class QueryRequest(BaseModel):
    user_input: str
    to_db: Optional[bool] = True
    model: Optional[str] = "gemini-2.0-flash"


@app.post('/chatbot')
async def chat_endpoint(
    query: QueryRequest, 
    project_id: Union[str, int] = Query(default=-1)
):
    
    project_id = str(project_id)
    if project_id.isdecimal():
        call_script(f"aino --project load {project_id}")
        call_script(f"aino --project select {project_id}")
    
    project_history = await get_history(project_id)
    try:
        output, log, updated_history = await process_query(
            user_input=query.user_input,
            to_db=query.to_db,
            model=query.model,
            chat_history=project_history,
        )
        await save_history(project_id, updated_history)
        
        return {
            "status": "success",
            "output": output,
            "log": log,
            "chat_history": updated_history
        }
    
    except Exception as e:
        logger.error(f"Error: {e}")
        return {
            "status": "error",
            "message": str(e)
        }

@app.get('/chat-history')
async def get_chat_history(project_id: Union[str, int] = Query(default=-1)):
    
    if str(project_id) == "-1":
        return {"status": "error", "message": "Retrieving all histories not supported here"}
    
    history = await get_history(project_id)
    
    return {
        "status": "success",
        "project_id": str(project_id),
        "chat_history": history,
    }

@app.delete("/clear-history")
async def clear_chat_history(project_id: Union[str, int] = Query(default=-1)):
    
    if str(project_id) == "-1":
        await clear_history()
        
    else :
        await clear_history(str(project_id))
        
    return {"status": "success", "message": "Chat history cleared."}



class CallCLIRequest(BaseModel):
    command: str

@app.post('/call-cli')
async def call_cli_endpoint(
    call_cli_request: CallCLIRequest,
    project_id: Union[str, int] = Query(default=-1)
):
    try:
        command = call_cli_request.command
        project_id = str(project_id)
        if project_id.isdecimal():
            call_script(f"aino --project load {project_id}")
            call_script(f"aino --project select {project_id}")
            
        output = await asyncio.to_thread(call_script, command)
        
        return {
            "status": "success",
            "output": output
        }
    
    except Exception as e:
        logger.error(f"Error: {e}")
        return {
            "status": "error",
            "message": str(e)
        }
