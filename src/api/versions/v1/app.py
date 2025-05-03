from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from utils import get_current_version
import sys
from mangum import Mangum
from fastapi.responses import JSONResponse
from fastapi import Request

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from routers import *

app = FastAPI(
    title=os.getenv("API_DOC_NAME", "Fast REST API"),
    version=f"{get_current_version()}.0.0",
    description="Deploy your aws rest api in minutes",
    cache_configuration={
        "enabled": False,
        "size": 0.5,  # Should be 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237
    },
)

app.openapi_version = "3.0.1"

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def catch_exceptions_middleware(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal Server Error"},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "*",
        },
    )


app.include_router(auth_router)
app.include_router(demo_router)


def lambda_handler(event, context):
    version = get_current_version()
    return Mangum(app, api_gateway_base_path=version).__call__(event, context)
