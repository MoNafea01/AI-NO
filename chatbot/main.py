import asyncio
from __init__ import *
from fastapi import FastAPI, Request, Query
from typing import Optional, Union
from starlette.middleware.sessions import SessionMiddleware

from pydantic import BaseModel
from cli.call_cli import call_script
from chatbot.utils import process_query
from chatbot.core.utils import init_logger, load_config

config = load_config('config/config.yaml')
logger = init_logger(__name__, config)

app = FastAPI()
app.add_middleware(SessionMiddleware, secret_key="1")

class QueryRequest(BaseModel):
    user_input: str
    to_db: Optional[bool] = True
    model: Optional[str] = "gemini-2.0-flash"

@app.post('/chatbot')
async def chat_endpoint(
    request: Request, 
    query: QueryRequest, 
    project_id: Union[str, int] = Query(default=-1)
):
    
    project_id = str(project_id)
    if project_id.isdecimal():
        call_script(f"aino --project load {project_id}")
        call_script(f"aino --project select {project_id}")
        
    try:
        output, log, updated_history = await process_query(
            user_input=query.user_input,
            to_db=query.to_db,
            model=query.model,
            chat_history=request.session.get("chat_history", []),
        )
        request.session["chat_history"] = updated_history
        
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
async def get_chat_history(request: Request):
    chat_history = request.session.get("chat_history", [])
    return {
        "status": "success",
        "chat_history": chat_history
    }

@app.delete("/clear-history")
async def clear_chat_history(request: Request):
    request.session["chat_history"] = []
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
