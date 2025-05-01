from fastapi import APIRouter, Depends
from api.auth import api_key_header, oauth2_scheme, get_user_id
import os


demo_router = APIRouter(tags=["demo"])


@demo_router.get(
    "/throttled",
    openapi_extra={
        "x-conf": {
            "throttling": {"rateLimit": 0.1, "burstLimit": 1},
        }
    },
)
async def test():
    return {"message": f"Hello, World version 2! "}


@demo_router.get("/unthrottled")
async def test():
    return {"message": f"Hello, World! {os.environ['MY_NAME']}"}


@demo_router.get("/hidden", include_in_schema=False)
async def hidden():
    return {
        "message": "The route is hidden from the api documentation but still available"
    }


@demo_router.get("/api-key-protected-route", dependencies=[Depends(api_key_header)])
async def test():
    return {"message": f"Hello, World! {os.environ['MY_NAME']}"}


@demo_router.get("/oauth2-protected-route", dependencies=[Depends(oauth2_scheme)])
async def test(token: str = Depends(oauth2_scheme)):
    user_id = get_user_id(token)
    return {"message": f"Hello, World! {os.environ['MY_NAME']} {user_id}"}


# @app.get("/custom-lambda", openapi_extra={"x-conf": {
#     "memory_size": 2024,
#     "timeout": 30
# }})
# async def test():
#     return {"message": f"Hello, World! {os.environ['AWS_LAMBDA_FUNCTION_NAME']}"}
