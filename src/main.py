import uvicorn

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, ConfigDict
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from .database import get_db
from .models import Product

app = FastAPI(title="product-api")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten in prod
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ProductCreate(BaseModel):
    product_id: int = Field(..., ge=1)
    title: str = Field(...)
    price: float = Field(...)
    category: str = Field(default="all")
    image: str = Field(...)
    description: str = Field(...)
    tag: str = Field(...)


class ProductOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    price: float
    category: str
    image: str
    description: str | None
    tag: str


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"} 


@app.get("/products", response_model=list[ProductOut])
async def products(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product))
    return result.scalars().all()


@app.get("/products/{id}", response_model=ProductOut)
async def product_by_id(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product).where(Product.id == id))
    product = result.scalar_one_or_none()

    if not product:
        raise HTTPException(status_code=404, detail=f"Product with id {id} does not exist")

    return product


@app.post("/products", status_code=201, response_model=ProductOut)
async def create_product(payload: ProductCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Product).where(Product.id == payload.product_id))
    product = result.scalar_one_or_none()

    if product:
        raise HTTPException(status_code=409, detail="Product already exists")

    new_product = Product(
        id=payload.product_id,
        title=payload.title,
        price=payload.price,
        category=payload.category,
        image=payload.image,
        description=payload.description,
        tag=payload.tag,
    )

    db.add(new_product)
    await db.commit()
    await db.refresh(new_product)
    return new_product


if __name__ == "__main__":
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000)
