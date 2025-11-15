from fastapi import FastAPI

app = FastAPI(title="Stellar Delivery Backend")


@app.get("/", tags=["root"])
async def read_root():
    return {"status": "ok", "service": "stellar-backend"}


# Add additional routers/endpoints under app as needed.
