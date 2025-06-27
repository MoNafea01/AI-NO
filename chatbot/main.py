from fastapi import FastAPI, Request
from starlette.middleware.sessions import SessionMiddleware

from pydantic import BaseModel
from app import process_query
from cli.call_cli import call_script

from chatbot.core.utils import init_logger, load_config
config = load_config('config/config.yaml')
logger = init_logger(__name__, config)

app = FastAPI()
app.add_middleware(SessionMiddleware, secret_key="1")

class QueryRequest(BaseModel):
    user_input: str
    to_db: bool
    model: str


@app.post('/chat')
async def chat_endpoint(request: Request, query: QueryRequest):
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


@app.post("/clear-history")
async def clear_chat_history(request: Request):
    request.session["chat_history"] = []
    return {"status": "success", "message": "Chat history cleared."}

@app.get('/chat-history')
async def get_chat_history(request: Request):
    chat_history = request.session.get("chat_history", [])
    return {
        "status": "success",
        "chat_history": chat_history
    }


@app.post('/call-cli')
async def call_cli_endpoint(request: Request):
    try:
        data = await request.json()
        command = data.get("command", "")
        output = call_script(command=command)
        
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
